# ~/.zprofile
# Ash Bellett

# Homebrew (Apple Silicon or Intel):
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Use every CPU core for make-based builds (e.g. native gem and Python extensions):
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"

export EDITOR="vim"
