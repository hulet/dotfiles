# originally from http://dotfiles.org/~delirio/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Vi keybindings
set -o vi
# from http://stackoverflow.com/questions/844862/bash-in-vi-mode-browsing-shell-history-with-cursor-up-down-cursor-position-not
bind -m vi-command '"\201": previous-history'
bind -m vi-command '"\202": next-history'
bind -m vi-command '"\203": end-of-line'
bind -m vi-command '"\e[A": "\201\203"'
bind -m vi-command '"\e[B": "\202\203"'
bind -m vi-command '"k": "\201\203"'
bind -m vi-command '"j": "\202\203"'
bind -m vi-insert '"\201": previous-history'
bind -m vi-insert '"\202": next-history'
bind -m vi-insert '"\203": end-of-line'
bind -m vi-insert '"\e[A": "\201\203"'
bind -m vi-insert '"\e[B": "\202\203"'

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

export EDITOR="vim" # programs will use this by default if you need to edit something
export VISUAL="vim" # some programs use this instead of EDITOR

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | xterm-256color | cygwin)
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\[\033[01;34m\]\h\[\033[00m\]:\[\033[01;31m\]\w\[\033[00m\]\$ '
    ;;
*)
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
    ;;
esac

# Comment in the above and uncomment this below for a color prompt
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    ;;
*)
    ;;
esac

# Alias definitions.

# -G works on mac and linux, but means different things
alias ls='ls -F -G'
# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    if ls --color=auto >&/dev/null; then
        eval "`dircolors -b`"
        # --color=auto only works on linux
        alias ls='ls -F --color=auto'
    fi
fi

# some more ls aliases
alias ll='ls -lah'
#alias la='ls -A'
#alias l='ls -CF'

# directory hops
alias u='cd ..'
alias ..='cd ..'

# safety first!
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias m='make'
alias py='python'
alias vi='vim'
alias s='svn'
alias g='git'


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


#PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
