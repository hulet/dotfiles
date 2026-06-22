# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal dotfiles managed by [dotbot](https://github.com/anishathalye/dotbot). Running `./install` symlinks config files into `~`, installs Homebrew packages, and runs post-install shell steps.

Needs to work on macOS, desktop linux, and headless linux on both personal and work machines.

## Install

```sh
./install                          # full install
./install --only create link       # symlinks only
./install --only plugins brewfile  # brew packages only
./install --only shell             # post-install shell steps only
```

The install script bootstraps dotbot from the `dotbot/` submodule and loads the `dotbot-plugins/dotbot-brew/` plugin for Brewfile support. Config is in `install.conf.yaml`.

## Architecture

**Symlink map** — `install.conf.yaml` is the authoritative list of what goes where. Each dotfile in the repo root symlinks to the appropriate `~` or `~/.config/` path.

**Platform branching** — `zshrc` has a `case "$(uname -s)"` block for macOS vs Linux differences. `Brewfile` uses `OS.mac?` / `OS.linux?` and a hostname check (`"AA"` = work laptop) for machine-specific packages.

**Shell stack** — Zsh + Zim Framework ([zimfw](https://github.com/zimfw/zimfw) modules listed in `zimrc`) + [starship](https://starship.rs) prompt. zimfw is installed via Homebrew and sourced from `$HOMEBREW_PREFIX/opt/zimfw/share/zimfw.zsh`. Local overrides go in `~/.zshrc.local` (not tracked).

**Neovim** — LazyVim distro (`nvim/`). Customizations live in `nvim/lua/`.

**Claude Code settings** — `settings.json` symlinks to `~/.claude/settings.json`. It configures permissions, plugins, etc.

**Ghostty** — Three-layer config: `ghostty.config` (base, sourced always) + `ghostty.linux.config` / `ghostty.macos.config` (platform-specific, symlinked conditionally).

**macOS Finder service** — `Open in Ghostty.workflow` is an Automator Quick Action symlinked to `~/Library/Services/` on macOS only.
