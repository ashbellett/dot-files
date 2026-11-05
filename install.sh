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
# Usage: ./install.sh [target ...]
#
# A target is a package or "toolchains". With none given, everything is
# installed. The brew package also installs Homebrew if it's missing, then
# everything in the Brewfile. It's macOS-only, so on Linux it's skipped and
# system packages are left alone. The toolchains target installs or updates
# rustup, uv, fnm and rbenv, and the latest Rust, Python, Node and Ruby.
#
# OS-specific steps live in install-macos.sh and install-linux.sh.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"

LOCAL_BIN="$HOME/.local/bin"    # uv and fnm
CARGO_BIN="$HOME/.cargo/bin"    # rustup
RBENV_ROOT="$HOME/.rbenv"

PACKAGES=()
for dir in "$DOTFILES"/*/; do
  PACKAGES+=("$(basename "$dir")")
done
TARGETS=("${PACKAGES[@]}" toolchains)

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

# Source the OS script, which defines os_check, package_supported, os_install
# and os_check_toolchain_deps.
load_os() {
  local os
  case "$(uname -s)" in
    Darwin) os=macos ;;
    Linux)  os=linux ;;
    *)      die "Unsupported OS: $(uname -s)" ;;
  esac
  # shellcheck source=/dev/null
  source "$DOTFILES/install-$os.sh"
  os_check
}

parse_args() {
  local arg
  for arg in "$@"; do
    case "$arg" in
      -h|--help) usage; exit 0 ;;
      -*)        die "Unknown option: $arg" ;;
      *)
        contains "$arg" "${TARGETS[@]}" \
          || die "Unknown target: $arg (available: ${TARGETS[*]})"
        package_supported "$arg" || die "The $arg package isn't supported on this OS"
        selected+=("$arg")
        ;;
    esac
  done
  if [[ ${#selected[@]} -eq 0 ]]; then
    local target
    for target in "${TARGETS[@]}"; do
      if package_supported "$target"; then
        selected+=("$target")
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

# Each installer below skips its shell setup, since ~/.zshrc already has it.

install_rust() {
  if command -v rustup >/dev/null; then
    info "Updating Rust"
    rustup update
  else
    info "Installing rustup and Rust"
    curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
      | sh -s -- -y --no-modify-path
  fi
}

install_python() {
  if command -v uv >/dev/null; then
    info "Updating uv"
    uv self update
  else
    info "Installing uv"
    curl -fsSL https://astral.sh/uv/install.sh \
      | env UV_INSTALL_DIR="$LOCAL_BIN" UV_NO_MODIFY_PATH=1 sh
  fi
  # --default also links python and python3 into ~/.local/bin.
  info "Installing the latest Python"
  uv python install --default
}

install_node() {
  if ! command -v fnm >/dev/null; then
    info "Installing fnm"
    # --force-install stops it deferring to Homebrew on macOS.
    curl -fsSL https://fnm.vercel.app/install \
      | bash -s -- --install-dir "$LOCAL_BIN" --skip-shell --force-install
  fi

  local version
  version="$(fnm ls-remote | awk 'END { print $1 }')" || true
  [[ -n $version ]] || die "Couldn't find the latest Node version"
  info "Installing Node $version"
  fnm list | grep -qwF "$version" || fnm install "$version"
  fnm default "$version"
}

# clone_or_pull <repo> <dir>
clone_or_pull() {
  if [[ -d "$2/.git" ]]; then
    git -C "$2" pull --ff-only --quiet
  else
    git clone --quiet "$1" "$2"
  fi
}

install_ruby() {
  info "Installing or updating rbenv and ruby-build"
  clone_or_pull https://github.com/rbenv/rbenv.git "$RBENV_ROOT"
  clone_or_pull https://github.com/rbenv/ruby-build.git "$RBENV_ROOT/plugins/ruby-build"

  # The list also has JRuby, TruffleRuby etc.; keep only CRuby releases.
  local version
  version="$(rbenv install --list 2>/dev/null \
    | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)" || true
  [[ -n $version ]] || die "Couldn't find the latest Ruby version"
  info "Installing Ruby $version"
  rbenv install --skip-existing "$version"
  rbenv global "$version"
}

install_toolchains() {
  local cmd
  for cmd in curl git; do
    command -v "$cmd" >/dev/null || die "$cmd is required to install the toolchains"
  done
  os_check_toolchain_deps

  export PATH="$CARGO_BIN:$LOCAL_BIN:$RBENV_ROOT/bin:$PATH"
  export RBENV_ROOT
  install_rust
  install_python
  install_node
  install_ruby
}

main() {
  load_os
  parse_args "$@"

  local target
  for target in "${selected[@]}"; do
    [[ $target == toolchains ]] || link_package "$target"
  done

  # Keep ~/.ssh, and the private keys in it, unreadable by other users.
  if contains ssh "${selected[@]}"; then
    chmod 700 "$HOME/.ssh"
  fi

  os_install

  if contains toolchains "${selected[@]}"; then
    install_toolchains
  fi

  if [[ -d "$BACKUP_DIR" ]]; then
    info "Replaced files backed up to $BACKUP_DIR"
  fi
  info "Done. Open a new shell to pick up the changes."
}

main "$@"
