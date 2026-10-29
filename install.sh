#!/usr/bin/env bash
#
# Install dotfiles on an Apple Silicon Mac or on Linux.
#
# Each top-level directory (brew, git, ...) is a package that mirrors $HOME.
# Every file in a package is symlinked to the same relative path under $HOME,
# so zsh/.zshrc -> ~/.zshrc and ssh/.ssh/config -> ~/.ssh/config. Existing
# files are moved to ~/.dotfiles-backup/<timestamp>/ before being replaced.
#
# Files ending in .local (e.g. ~/.gitconfig.local) are templates for
# machine-specific settings. They're copied into place only if missing, and
# never linked or overwritten, so local edits stay out of the repo.
#
# Usage: ./install.sh [package ...]
#
# With no packages given, all packages are installed. The brew package also
# installs Homebrew if it's missing, then everything in the Brewfile. It's
# macOS-only, so on Linux it's skipped and system packages are left alone.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
BREW=/opt/homebrew/bin/brew

PACKAGES=()
for dir in "$DOTFILES"/*/; do
  PACKAGES+=("$(basename "$dir")")
done

# Packages that only make sense on macOS.
MACOS_ONLY=(brew)

OS=
selected=()

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31mError:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  # Print the header comment, from line 3 up to the first blank line.
  sed -n '3,/^$/s/^# \{0,1\}//p' "${BASH_SOURCE[0]}"
}

# contains <item> <list ...>: succeed if item is one of the list's words.
contains() {
  local item="$1"
  shift
  [[ " $* " == *" $item "* ]]
}

detect_os() {
  case "$(uname -s)" in
    Darwin)
      [[ "$(uname -m)" == arm64 ]] || die "Only Apple Silicon Macs are supported"
      OS=macos
      ;;
    Linux) OS=linux ;;
    *)     die "Unsupported OS: $(uname -s)" ;;
  esac
}

parse_args() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      -h|--help) usage; exit 0 ;;
      -*)        die "Unknown option: $arg" ;;
      *)
        contains "$arg" "${PACKAGES[@]}" \
          || die "Unknown package: $arg (available: ${PACKAGES[*]})"
        if [[ $OS != macos ]] && contains "$arg" "${MACOS_ONLY[@]}"; then
          die "The $arg package is macOS-only"
        fi
        selected+=("$arg")
        ;;
    esac
  done
  if [[ ${#selected[@]} -eq 0 ]]; then
    local package
    for package in "${PACKAGES[@]}"; do
      if [[ $OS == macos ]] || ! contains "$package" "${MACOS_ONLY[@]}"; then
        selected+=("$package")
      fi
    done
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
    mkdir -p "$(dirname "$BACKUP_DIR/$rel")"
    mv "$dest" "$BACKUP_DIR/$rel"
  fi

  printf '    link     ~/%s\n' "$rel"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
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
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
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

# Install Homebrew if missing, then everything in ~/.Brewfile.
install_brew_packages() {
  if [[ ! -x "$BREW" ]]; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -x "$BREW" ]] || die "Homebrew install finished but $BREW is missing"
  fi

  info "Installing Brewfile packages"
  "$BREW" bundle --global
}

main() {
  detect_os
  parse_args "$@"

  local package
  for package in "${selected[@]}"; do
    link_package "$package"
  done

  # Keep ~/.ssh, and the private keys in it, unreadable by other users.
  if contains ssh "${selected[@]}"; then
    chmod 700 "$HOME/.ssh"
  fi

  if contains brew "${selected[@]}"; then
    install_brew_packages
  fi

  if [[ -d "$BACKUP_DIR" ]]; then
    info "Replaced files backed up to $BACKUP_DIR"
  fi
  info "Done. Open a new shell to pick up the changes."
}

main "$@"
