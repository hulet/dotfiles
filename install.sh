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

function symlinkifne {
    running "$1"
    FILENAME=$1
    DOTFILENAME=.$FILENAME

    if [[ ! -e $FILENAME ]]; then
        echo -en '\ttarget file does not exist, skipped\t';warn
        return
    fi

    if [[ -L ~/$DOTFILENAME ]]; then
        # it's already a simlink (could have come from this project)
        echo -en '\tsimlink exists, skipped\t';ok
        return
    fi
    if [[ -e ~/$DOTFILENAME ]]; then
        # file exists
        if [[ ! -e ~/.dotfiles_backup.$TIMESTAMP/$DOTFILENAME ]]; then
            # backup file does not exist yet
            mv ~/$DOTFILENAME ~/.dotfiles_backup.$TIMESTAMP/
            echo -en 'backed up saved...';
        fi
    fi
    # create the link
    ln -s `pwd`/$FILENAME ~/$DOTFILENAME 
    echo -en 'linked\t';ok
}

bot "creating symlinks for project dotfiles..."

symlinkifne bashrc
symlinkifne gitconfig
symlinkifne grep-exclude
symlinkifne screenrc
symlinkifne vim
symlinkifne vimrc
symlinkifne zshrc

# cleanup
rmdir ~/.dotfiles_backup.$TIMESTAMP > /dev/null 2>&1

#./osx.sh

bot "Woot! All done."

