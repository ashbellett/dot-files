# Dot Files

My personal dot files for macOS.

## Layout

Each top-level directory (`brew`, `claude`, `git`, `ssh`, `zsh`) is a package
for one tool, laid out to mirror `$HOME`: `zsh/.zshrc` installs to `~/.zshrc`,
`ssh/.ssh/config` to `~/.ssh/config`, and so on.

To add a file, put it in the package at the path it should have relative to
`$HOME`. The installer picks it up automatically.

## Install

```sh
git clone https://github.com/ashbellett/dot-files.git ~/Code/dot-files
cd ~/Code/dot-files
./install.sh
```

The installer:

1. Symlinks every file in each package into `$HOME`. Existing files are moved
   to `~/.dotfiles-backup/<timestamp>/` first.
2. Sets permissions on `~/.ssh`.
3. If the `brew` package is selected, installs Homebrew if it's missing, then
   everything in the Brewfile (`brew bundle --global`).

Re-running it is safe: files that are already linked are left alone.

```sh
./install.sh --dry-run      # preview changes
./install.sh zsh git        # install only some packages
./install.sh --no-brew      # skip Homebrew entirely
```

## Machine-specific settings

These files are sourced if they exist but are not tracked:

- `~/.zshrc.local`
- `~/.gitconfig.local` (put your `[user]` name and email here)
- `~/.ssh/config.local`
