# ~/.zshrc

# History:
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY

# Toolchains (installed by install.sh):
# rustup puts Rust in ~/.cargo/bin, uv and fnm live in ~/.local/bin (uv also
# links python and python3 there), and rbenv lives in ~/.rbenv. Set up before
# compinit so their completions are picked up.
typeset -U path
path=("$HOME/.cargo/bin" "$HOME/.local/bin" "$HOME/.rbenv/bin" $path)
(( $+commands[fnm] )) && eval "$(fnm env --use-on-cd --shell zsh)"
(( $+commands[rbenv] )) && eval "$(rbenv init - zsh)"

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

# Machine-specific overrides (not tracked):
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
