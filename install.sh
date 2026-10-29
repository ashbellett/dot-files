#!/usr/bin/env bash
#
# Install dotfiles on macOS.
#
# Each top-level package directory (brew, git, ...) mirrors $HOME. Every file
# in a package is symlinked to the same relative path under $HOME, so
# zsh/.zshrc -> ~/.zshrc and ssh/.ssh/config -> ~/.ssh/config. Existing files
# are moved to ~/.dotfiles-backup/<timestamp>/ before being replaced.
#
# Files ending in .local (e.g. ~/.gitconfig.local) are templates for
# machine-specific settings. They're copied into place only if missing, and
# never linked or overwritten, so local edits stay out of the repo.
#
# Usage: ./install.sh [options] [package ...]
#
# Options:
#   -n, --dry-run   Show what would happen without changing anything
#   --no-brew       Skip installing Homebrew and Brewfile packages
#   -h, --help      Show this help
#
# With no packages given, all packages are installed.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(brew claude git ssh zsh)
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

dry_run=false
with_brew=true
backed_up=false
selected=()

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

# Run a command unless this is a dry run.
run() {
  $dry_run || "$@"
}

usage() {
  # Print the header comment, from line 3 up to the first blank line.
  sed -n '3,/^$/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

is_package() {
  local package
  for package in "${PACKAGES[@]}"; do
    [[ "$package" == "$1" ]] && return 0
  done
  return 1
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n|--dry-run) dry_run=true ;;
      --no-brew)    with_brew=false ;;
      -h|--help)    usage; exit 0 ;;
      -*)           die "Unknown option: $1" ;;
      *)
        is_package "$1" || die "Unknown package: $1 (available: ${PACKAGES[*]})"
        selected+=("$1")
        ;;
    esac
    shift
  done
  if [[ ${#selected[@]} -eq 0 ]]; then
    selected=("${PACKAGES[@]}")
  fi
}

# Symlink $DOTFILES/<package>/<path> to $HOME/<path>.
link_file() {
  local src="$1" rel="$2"
  local dest="$HOME/$rel"

  if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
    printf '    ok       ~/%s\n' "$rel"
    return
  fi

  if [[ -e "$dest" || -L "$dest" ]]; then
    printf '    backup   ~/%s\n' "$rel"
    backed_up=true
    run mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    run mv "$dest" "$BACKUP_DIR/$rel"
  fi

  printf '    link     ~/%s\n' "$rel"
  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
}

# Copy a .local template to $HOME/<path>, unless something is already there.
copy_template() {
  local src="$1" rel="$2"
  local dest="$HOME/$rel"

  if [[ -e "$dest" || -L "$dest" ]]; then
    printf '    exists   ~/%s\n' "$rel"
    return
  fi

  printf '    create   ~/%s\n' "$rel"
  run mkdir -p "$(dirname "$dest")"
  run cp "$src" "$dest"
}

link_package() {
  local package="$1" src rel
  info "Linking $package"
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES/$package/"}"
    if [[ "$rel" == *.local ]]; then
      copy_template "$src" "$rel"
    else
      link_file "$src" "$rel"
    fi
  done < <(find "$DOTFILES/$package" \( -type f -o -type l \) ! -name .DS_Store -print0 | sort -z)
}

# ssh ignores config files that are writable by others.
fix_ssh_permissions() {
  info "Setting ~/.ssh permissions"
  run mkdir -p "$HOME/.ssh"
  run chmod 700 "$HOME/.ssh"
  run chmod 600 "$DOTFILES/ssh/.ssh/config"
  if [[ -f "$HOME/.ssh/config.local" ]]; then
    run chmod 600 "$HOME/.ssh/config.local"
  fi
}

# Put Homebrew on PATH for the rest of this script, if it's installed.
load_brew() {
  local prefix
  for prefix in /opt/homebrew /usr/local; do
    if [[ -x "$prefix/bin/brew" ]]; then
      eval "$("$prefix/bin/brew" shellenv)"
      return 0
    fi
  done
  return 1
}

# Install Homebrew if missing, then everything in ~/.Brewfile.
install_brew_packages() {
  if load_brew; then
    info "Homebrew found at $(command -v brew)"
  elif $dry_run; then
    info "Would install Homebrew from https://brew.sh"
  else
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    load_brew || die "Homebrew installed but brew is not on PATH"
  fi

  info "Installing Brewfile packages"
  run brew bundle --global
}

main() {
  parse_args "$@"
  [[ "$(uname -s)" == "Darwin" ]] || die "This script only supports macOS"
  $dry_run && info "Dry run: nothing will be changed"

  local package
  for package in "${selected[@]}"; do
    link_package "$package"
    [[ "$package" == ssh ]] && fix_ssh_permissions
  done

  if $with_brew && [[ " ${selected[*]} " == *" brew "* ]]; then
    install_brew_packages
  fi

  if $backed_up && $dry_run; then
    info "Replaced files would be backed up to $BACKUP_DIR"
  elif $backed_up; then
    info "Replaced files backed up to $BACKUP_DIR"
  fi
  info "Done. Open a new shell to pick up the changes."
}

main "$@"
