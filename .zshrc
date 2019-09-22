# ~/.zshrc
# Ash Bellett

# Variables:

export PATH=$PATH:/home/ash/.local/bin

# Sound:

# No sound:
setopt NO_BEEP

# History:

# Location of history file:
HISTFILE=~/.zhist
# Number of commands saved per session:
HISTSIZE=128
# Number of commands saved overall:
SAVEHIST=128
# Save timestamp and execution duration:
setopt EXTENDED_HISTORY
# Ignore duplicate commands:
setopt HIST_IGNORE_DUPS

# Completion:

# Load completion:
autoload -Uz compinit
# Start completion:
compinit
# Set completion style:
zstyle ':completion:*' menu select

# Prompt:

# Load prompt:
autoload -Uz promptinit
# Start prompt:
promptinit
# Define left prompt:
PROMPT='%B%n%b: ' # boldface username
# Define right prompt:
RPROMPT='%/' # current directory
