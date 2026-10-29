# ~/.zshrc

# History:
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Completions:
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Prompt:
PROMPT='%B%n%b: ' # boldface username
RPROMPT='%~'      # current directory

# Homebrew:
# Update Homebrew, install or upgrade everything in ~/.Brewfile, then offer to
# uninstall anything not listed in it, such as the old Python once Homebrew's
# default moves to a new version. Finishes by removing old versions, unused
# dependencies and every cached download.
brew-sync() {
  brew update && brew bundle --global || return

  local removals
  removals="$(brew bundle cleanup --global |
    awk '/^Would `brew cleanup`/ { exit } /^Would uninstall/ { found = 1 } found')"

  if [[ -n $removals ]]; then
    print -r -- "$removals"
    if read -q "?Uninstall these? [y/N] "; then
      echo
      brew bundle cleanup --global --force || return
    else
      echo
    fi
  fi

  brew cleanup --prune=all
}

# Aliases:
alias b=brew-sync
alias python=python3

# Machine-specific overrides (not tracked):
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
