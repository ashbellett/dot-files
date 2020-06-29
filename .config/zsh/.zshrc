#! /bin/zsh

# ~/.zshrc
# Ash Bellett

# History:

# Location of history file:
HISTFILE=~/.cache/zsh/zhistory
# Number of commands saved per session:
HISTSIZE=1024
# Number of commands saved overall:
SAVEHIST=1024
# Save timestamp and execution duration:
setopt EXTENDED_HISTORY
# Ignore duplicate commands:
setopt HIST_IGNORE_DUPS

# Completion:

# Load completion:
autoload -Uz compinit
# Set completion style:
zstyle ':completion:*' menu select
# Start completion:
compinit
# Auto-complete aliases
setopt COMPLETE_ALIASES

# Prompt:

# Load prompt:
autoload -Uz promptinit
# Define left prompt:
PROMPT='%B%n%b: ' # boldface username
# Define right prompt:
RPROMPT='%/' # current directory
# Start prompt:
promptinit
# Add Gentoo completions
prompt gentoo
