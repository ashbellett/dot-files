# ~/.zshrc
# Ash Bellett

# History:
HISTFILE=~/.zsh_history
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

# Machine-specific overrides (not tracked):
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
