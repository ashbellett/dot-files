# ~/.zprofile

# Homebrew:
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Use every CPU core for make-based builds (e.g. native gem and Python extensions):
export MAKEFLAGS="-j$(getconf _NPROCESSORS_ONLN)"

export EDITOR="vim"
