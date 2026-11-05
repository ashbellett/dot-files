# Linux steps for install.sh. Sourced by it, not run directly.
#
# System packages are left to the distro's package manager: this script only
# checks that the ones the toolchains need are present.

os_check() { :; }

# package_supported <package>: Homebrew is only used on macOS.
package_supported() { [[ $1 != brew ]]; }

os_install() { :; }

# Rust and Ruby need a C toolchain, and fnm's installer needs unzip. Ruby also
# needs the OpenSSL, libyaml, zlib and libffi headers, which can't be checked
# for reliably here; ruby-build reports them if they're missing.
os_check_toolchain_deps() {
  local cmd missing=()
  for cmd in cc make unzip; do
    command -v "$cmd" >/dev/null || missing+=("$cmd")
  done
  [[ ${#missing[@]} -eq 0 ]] || die "Missing ${missing[*]}. On Debian/Ubuntu:
  sudo apt install build-essential unzip libssl-dev libyaml-dev zlib1g-dev libffi-dev"
}
