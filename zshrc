# ~/.zshrc
#
# $Revision$
# $Date$
# $Author$
#

# Vi keybindings
bindkey -v

# arrow keys are not properly bound in Ubuntu vi key bindings; bind them here
# from http://www.zsh.org/mla/users/2001/msg00074.html
bindkey -M viins '^[[D' vi-backward-char '^[[C' vi-forward-char '^[[A' up-line-or-history '^[[B' down-line-or-history

export EDITOR="vim" # programs will use this by default if you need to edit something
export VISUAL="vim" # some programs use this instead of EDITOR

# ensures that I can delete over stuff that was done in a previous insert
# session, not proper vi action
bindkey -M viins '' backward-delete-char
bindkey -M viins '' backward-delete-char
stty ek

# To discover the proper keys, in vi mode type: ^v then the key
bindkey '^[[3~' delete-char
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line

HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=2000
setopt appendhistory

# PROMPT explination:
# $=' needed for colors
# %{\e[1;32m%} sets our first color. 32 is the color, changed as needed
# always end with color 00 so the CL is normal
# %n: username, %m: hostname, %1~: display the pwd (if $HOME then ~) one level
# %(!.#.$): if (su_priv) then # else $
PROMPT=$'%(!.%{\e[1;31m%}.%{\e[1;32m%})%n@%{\e[1;34m%}%m:%{\e[1;31m%}%1~%{\e[1;00m%}%(!.#.$) '

# RPROMPT (shows up at the end of a line)
# if (exit code wasn't bad) then else display the exit code
#RPROMPT='%(?..%?)'
RPROMPT=$'%{\e[0;31m%}%d %{\e[0;34m%}[%T]%{\e[0;00m%} %(?.%?.%?)'

# from http://dotfiles.org/~_why/.zshrc
# format titles for screen and rxvt
function title() {
  # escape '%' chars in $1, make nonprintables visible
  a=${(V)1//\%/\%\%}

  # Truncate command, and join lines.
  a=$(print -Pn "%40>...>$a" | tr -d "\n")

  case $TERM in
  screen)
    print -Pn "\ek$a:$3\e\\"      # screen title (in ^A")
    ;;
  xterm*|rxvt)
    print -Pn "\e]2;$2 | $a:$3\a" # plain xterm title
    ;;
  esac
}
# precmd is called just before the prompt is printed
function precmd() {
  title "zsh" "$USER@%m" "%55<...<%~"
}
# preexec is called just before any command line is executed
function preexec() {
  title "$1" "$USER@%m" "%35<...<%~"
}


# Make cd actually do pushd too
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# Enhances tab-completion
autoload -U compinit 
compinit

# colorful listings
zmodload -i zsh/complist
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

## case-insensitive (all),partial-word and then substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# from "Writing Zsh Completion Functions" in Lunix Magazine
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*' group-name ''

# completion settings.
## I don't like having a horde of users, and want some specific machines for ssh
#zstyle ':completion:*' hosts somehost.something.net
#zstyle ':completion:*' users myuser root

export PATH="$PATH:$HOME/bin:$HOME/svn/scripts"

disable r

# ls colors
#eval `dircolors -b /etc/DIR_COLORS`
# -G works on mac and linux, but means different things
alias ls='ls -F -G'
if ls --color=auto >&/dev/null; then
    # --color=auto only works on linux
    alias ls='ls -F --color=auto'
fi
alias ll='ls -lah'

# directory hops
alias u='cd ..'
alias uu='cd ../..'
alias ..='cd ..'
alias cddl='cd ~/Downloads/'
alias cdd='cd ~/data/'
alias cdt='cd /tmp/'
alias cdvt='cd /var/tmp/'
alias cdao='cd /sites/sites/aiaonline.org/'
alias cda3='cd ~/svn/aia365/trunk/aia365.com/'

# safety first!
alias rm='nocorrect rm -i'
alias cp='nocorrect cp -i'
alias mv='nocorrect mv -i'
alias mkdir='nocorrect mkdir'

alias du0='du -hcs'
alias eject='eject -v'
alias grep='grep --color=auto --exclude-dir=".svn"'
alias svnmissing='svn status | grep "^\?" | sed -e "s/\?      //"'
alias svnaddmissing='svn status | grep "^\?" | sed -e "s/\?      //" | xargs svn add'
alias m='make'
alias py='python'
alias vi='vim'
alias s='svn'
alias g='git'
alias gitversion='git rev-parse --verify HEAD'
alias sag='sudo apachectl graceful'

alias dh='ssh hulet@ideaharbor.org'
alias db='ssh b192161@hanjin.dreamhost.com'

alias mcd='sudo mount -t auto /dev/cdrom /media/cdrom'
alias ucd='sudo umount /media/cdrom'
alias musb='sudo mount -t auto -o uid=1000,noatime /dev/sda1 /media/usbdisk'
alias mmusb='sudo mount -o rw,remount /media/usbdisk'  # remount as read-write
alias uusb='sudo umount /media/usbdisk'
alias ump3='sudo umount /media/SANSA\ M350'
alias passgen='head /dev/urandom | uuencode -m - | sed -ne 2p |  sed -e "s/[0oOiIlL1\+\\\/]//g" | cut -c-12'
alias passgen2='head /dev/urandom | uuencode -m - | sed -ne 2p |  sed -e "s/[0oOiIlL1\+\\\/]//g"'
alias findsymlinks='find . -type l -exec ls -l {} \;'

# rails
alias rdm='rake db:migrate'
alias rdm0='rake db:migrate VERSION=0'
alias rdmp='rake db:migrate RAILS_ENV=production'
alias ss='./script/server'
alias ttr='touch tmp/restart.txt'  # for Passenger

# platform specific
 case `uname` in
     Darwin)
     export JAVA_HOME='/Library/Java/Home'
     alias du1='du -hc -d 1'
     alias te='open -a TextEdit'
     alias tel='tail -f /var/log/apache2/error_log'
     alias tal='tail -f /var/log/apache2/access_log'
     export PATH="/usr/local/bin:$PATH"  # for homebrew
     [[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" # This loads RVM into a shell session.
     PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

     # Android SDK
     PATH=${PATH}:~/bin/android-sdk-macosx/tools:~/bin/android-sdk-macosx/platform-tools
     ;;
     Linux)
     alias open='xdg-open'
     alias du1='du -hc --max-depth 1'
     ;;
 esac

# local config overrides all
if [[ -f $HOME/.zshrc.local ]]; then
    source $HOME/.zshrc.local
fi


