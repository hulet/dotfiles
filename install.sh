#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# Based on install.sh by Adam Eivy
# https://github.com/atomantic/dotfiles/blob/master/install.sh
###########################

# include library helpers for colorized echo and require_brew, etc
source ./lib.sh

# make a backup directory for existing dotfiles
TIMESTAMP=`date +%Y-%m-%d-%H-%M-%S`
bot $TIMESTAMP
mkdir ~/.dotfiles_backup.$TIMESTAMP

if [[ $SHELL == */zsh ]]; then
	bot "looks like you are already using zsh. woot!"
else
	running "changing your login shell to zsh"
	chsh -s $(which zsh);ok
fi

pushd ~ > /dev/null 2>&1

function symlinkifne {
    running "$1"

    if [[ -L $1 ]]; then
        # it's already a simlink (could have come from this project)
        echo -en '\tsimlink exists, skipped\t';ok
        return
    fi
    if [[ -e $1 ]]; then
        # file exists
        if [[ ! -e ~/.dotfiles_backup.$TIMESTAMP/$1 ]]; then
            # backup file does not exist yet
            mv $1 ~/.dotfiles_backup.$TIMESTAMP/
            echo -en 'backed up saved...';
        fi
    fi
    # create the link
    ln -s ~/.dotfiles/$1 $1
    echo -en 'linked\t';ok
}

bot "creating symlinks for project dotfiles..."

symlinkifne .screenrc
symlinkifne .vimrc
symlinkifne .zshrc

# cleanup
rmdir ~/.dotfiles_backup.$TIMESTAMP > /dev/null 2>&1

popd > /dev/null 2>&1

#./osx.sh

bot "Woot! All done."

