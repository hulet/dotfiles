# ~/.zshrc
#
#

# disable zsh command so we can use r programming language
disable r

# vi bindings, per https://github.com/zimfw/input
bindkey -v

# accept suggestions with Control + Space
bindkey '^ ' autosuggest-accept


# --- ENVIRONMENT VARIABLES ---
export EDITOR="vim" # programs will use this by default if you need to edit something
export VISUAL="vim" # some programs use this instead of EDITOR

export PATH="$PATH:$HOME/bin:$HOME/svn/scripts"

# pipx executables are installed here
export PATH="$HOME/.local/bin:$PATH"

export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/ripgrep.conf"

# https://github.com/eza-community/eza-themes
# https://github.com/eza-community/eza/issues/1224
export EZA_CONFIG_DIR=~/.config/eza

# https://github.com/folke/tokyonight.nvim/blob/main/extras/fzf/tokyonight_night.sh
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none \
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"

# --- CUSTOM ALIASES ---
# directory hops
alias u='cd ..'
alias uu='cd ../..'
alias uuu='cd ../../..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias cdd='cd ~/data/'
alias cddl='cd ~/Downloads/'
alias cdg='cd ~/git/'
alias cdt='cd /tmp/'
alias cdvt='cd /var/tmp/'

# safety first!
alias rm='nocorrect rm -i'
alias cp='nocorrect cp -i'
alias mv='nocorrect mv -i'
alias mkdir='nocorrect mkdir'

# Utils
alias du0='du -hcs'
alias eject='eject -v'
if [[ -e $HOME/.grep-exclude ]]; then
    alias grep='grep --color=auto --exclude-dir="vendor/ckeditor" --exclude-dir="editors/ckeditor" --exclude-dir="editors/tinymce" --exclude-dir="node_modules" --exclude-dir=".svn" --exclude-dir=".git" --exclude-dir="cache" --exclude-dir="sessions" --exclude-from ~/.grep-exclude'
else
    alias grep='grep --color=auto --exclude-dir="vendor/ckeditor" --exclude-dir="editors/ckeditor" --exclude-dir="editors/tinymce" --exclude-dir="node_modules" --exclude-dir=".svn" --exclude-dir=".git" --exclude-dir="cache" --exclude-dir="sessions"'
fi
alias bbgrep='grep --exclude-dir="files" --exclude-dir="var" --exclude-dir="images"'
alias m='make'
alias py='python'
alias python='python3'
alias vi='nvim'
alias fvi='vim -u NONE'
alias myip='curl -w "\n" http://api.ipify.org'
alias caly='cal `date +%Y`'

# Git / SVN / Docker / Terraform
alias s='svn'
alias g='git'
alias gcm='git clone --mirror '
alias gpm='git push origin --mirror'
alias lg='lazygit'
alias dk='docker'
alias dc='docker-compose'
alias gitversion='git rev-parse --verify HEAD'
alias svnmissing='svn status | grep "^\?" | sed -e "s/\?      //"'
alias svnaddmissing='svn status | grep "^\?" | sed -e "s/\?      //" | xargs svn add'
alias tf='terraform'

# System / Apache
alias sag='sudo apachectl graceful'
alias hosts='sudo vi /etc/hosts'
alias ftraceroute='traceroute -q 1 -w 1'
alias findsymlinks='find . -type l -exec ls -l {} \;'
alias recursivesortbydate='find . -type f -exec stat -lt "%Y-%m-%d" {} \+ | cut -d" " -f6- | sort -n'

# Custom Password Generators
#alias passgen='head /dev/urandom | uuencode -m - | sed -ne 2p | sed -e "s/[0oOiIlL1\+\\\/]//g" | cut -c-12'
alias passgen='head /dev/urandom | uuencode -m - | sed -ne 2p | sed -e "s/[0oOiIlL1\+\\\/]//g" | grep -o ".\{11\}[2-9]" | head -1'
alias passgen2='head /dev/urandom | uuencode -m - | paste -s -d ";" - | sed -e "s/;//g" | cut -d " " -f3 | sed -e "s/[0oOiIlL1\+\\\/]//g" | grep -o ".\{10\}[0-9][2-7]" | head -1 | sed -e "s/[0-9]/_/"'
alias passgen3='head /dev/urandom | uuencode -m - | sed -ne 2p | sed -e "s/[0oOiIlL1\+\\\/]//g" | grep -o ".\{32\}" | head -1'
alias passgen4='head /dev/urandom | uuencode -m - | sed -ne 2p | sed -e "s/[0oOiIlL1\+\\\/]//g"'

# Rails
alias rdm0='rake db:migrate VERSION=0'
alias rdm='rake db:migrate'
alias rdmp='rake db:migrate RAILS_ENV=production'
alias ss='./script/server'
alias ttr='touch tmp/restart.txt'  # for Passenger

# WordPress
#alias wpdb="mysql -u $(cat wp-config.php|grep -w DB_USER|cut -d\' -f 4) -p$(cat wp-config.php|grep -w DB_PASSWORD|cut -d\' -f 4) -h $(cat wp-config.php|grep -w DB_HOST|cut -d\' -f 4) -D $(cat wp-config.php|grep -w DB_NAME|cut -d\' -f 4)"


# --- FUNCTIONS ---
wk() {
    echo `date` $@ >> ~/worklog.txt
}

# --- PLATFORM SPECIFIC ---
case `uname` in
    Darwin)
    export JAVA_HOME='/Library/Java/Home'
    alias du1='du -hc -d 1'
    alias du1s='du -c -d 1 | sort -nr'
    alias tal='tail -f /usr/local/var/log/httpd/access_log'
    alias tel='tail -f /usr/local/var/log/httpd/error_log | grep -v "File does not exist:"'
    alias te='open -a TextEdit'
    alias vhosts='sudo vi /etc/apache2/extra/httpd-vhosts.conf'
    alias tailsql='tail -f /usr/local/var/mysql/sheeta.log'
    alias dockerinit='$(boot2docker shellinit)'
    alias unquarantine='xattr -d com.apple.quarantine'
    alias dnscacheflush='sudo discoveryutil udnsflushcaches'
    alias lk="open -a /System/Library/CoreServices/ScreenSaverEngine.app"

    if [ -x "/opt/homebrew/bin/brew" ]; then
      # Apple Silicon macOS
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x "/usr/local/bin/brew" ]; then
      # Intel macOS
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    export PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"

    # Fresh custom bins
    export PATH=${PATH}:/usr/local/fresh-public-scripts/bin

    # For MAMP
    export PATH="$PATH:/Applications/MAMP/bin/php/php8.2.0/bin:/Applications/MAMP/Library/bin/"
    ;;

    Linux)
    alias du1='du -hc --max-depth 1'
    alias du1s='du -c --max-depth 1 | sort -nr'

    open() {
      xdg-open "$@" >/dev/null 2>&1 &|
    }

    if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    ;;

esac


# --- Zim Framework ---
# assumes zimfw is installed via Homebrew on systems where Homebrew is used
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim
# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
    if [[ -n "${HOMEBREW_PREFIX}" ]]; then
        source $HOMEBREW_PREFIX/opt/zimfw/share/zimfw.zsh init
    else
        echo "need to source zim init"
    fi
fi
# Initialize modules.
source ${ZIM_HOME}/init.zsh

# Bind '/' in Vi Normal Mode to FZF History
bindkey -M vicmd '/' fzf-history-widget

# don't mix up commands between terminal tabs
setopt NO_SHARE_HISTORY

if [ -d "/usr/local/Caskroom/google-cloud-sdk" ]
then
    # needs to come after zim initializes the completion module
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi

# override ls alias in zim utility module
if command -v eza &> /dev/null; then
    alias ls='eza --group-directories-first --icons=auto'
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
fi

# from https://github.com/basecamp/omarchy/blob/master/default/bash/aliases
if command -v zoxide &> /dev/null; then
  alias cd="zd"
  zd() {
    if [ $# -eq 0 ]; then
      builtin cd ~ && return
    elif [ -d "$1" ]; then
      builtin cd "$1"
    else
      z "$@" && printf "    \U000F17A9 " && pwd || echo "Error: Directory not found"
    fi
  }
fi

if command -v starship &> /dev/null; then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# --- LOCAL OVERRIDES ---
# local config overrides all
if [[ -f $HOME/.zshrc.local ]]; then
    source $HOME/.zshrc.local
fi
