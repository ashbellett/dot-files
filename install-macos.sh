# macOS steps for install.sh. Sourced by it, not run directly.

BREW=/opt/homebrew/bin/brew

os_check() {
  [[ "$(uname -m)" == arm64 ]] || die "Only Apple Silicon Macs are supported"
}

# package_supported <package>: every package works on macOS.
package_supported() { true; }

# Install Homebrew if missing, then everything in ~/.Brewfile. Runs before the
# toolchains so the libraries Ruby builds against (openssl@3, libyaml) exist.
os_install() {
  contains brew "${selected[@]}" || return 0

  if [[ ! -x "$BREW" ]]; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    [[ -x "$BREW" ]] || die "Homebrew install finished but $BREW is missing"
  fi

  info "Installing Brewfile packages"
  "$BREW" bundle --global
}

# Rust and Ruby need a C compiler, which comes with the Command Line Tools.
# /usr/bin/cc always exists on macOS, so check for the tools themselves.
os_check_toolchain_deps() {
  xcode-select -p >/dev/null 2>&1 \
    || die "Install the Xcode Command Line Tools first: xcode-select --install"
}
