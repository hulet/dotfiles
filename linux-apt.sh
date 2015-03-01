#!/usr/bin/env bash

## with help from https://github.com/atomantic/dotfiles/blob/master/osx.sh
## and https://github.com/kitchenplan/chef-osxdefaults/tree/master/recipes

# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh

# Ask for the administrator password upfront
bot "I need you to enter your sudo password so I can install some things:"
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

bot "OK, let's roll..."


bot "installing packages"
apt-get install -y \
    exuberant-ctags \
    zsh \
