# ~/.zshrc
#
#

# disable zsh command so we can use r programming language
disable r

# accept suggestions with Control + Space
bindkey '^ ' autosuggest-accept


# --- ENVIRONMENT VARIABLES ---
export EDITOR="vim" # programs will use this by default if you need to edit something
export VISUAL="vim" # some programs use this instead of EDITOR

export PATH="$PATH:$HOME/bin:$HOME/svn/scripts"

# Created by `pipx` on 2023-04-03 18:32:05
export PATH="$PATH:/Users/hulet/Library/Python/3.11/bin"

# Created by `pipx` on 2023-04-03 18:32:06
export PATH="$PATH:/Users/hulet/.local/bin"


# --- CUSTOM ALIASES ---
# directory hops
alias u='cd ..'
alias uu='cd ../..'
alias ..='cd ..'
alias cddl='cd ~/Downloads/'
alias cdd='cd ~/data/'
alias cdg='cd ~/git/'
alias cdt='cd /tmp/'
alias cdvt='cd /var/tmp/'

# safety first!
alias rm='nocorrect rm -i'
alias cp='nocorrect cp -i'
alias mv='nocorrect mv -i'
alias mkdir='nocorrect mkdir'

# Utils
alias ll='ls -lah'
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
alias vi='vim'
alias fvi='vim -u NONE'
alias myip='curl -w "\n" http://api.ipify.org'
alias caly='cal `date +%Y`'

# Git / SVN / Docker
alias s='svn'
alias g='git'
alias gcm='git clone --mirror '
alias gpm='git push origin --mirror'
alias dk='docker'
alias dc='docker-compose'
alias gitversion='git rev-parse --verify HEAD'
alias svnmissing='svn status | grep "^\?" | sed -e "s/\?      //"'
alias svnaddmissing='svn status | grep "^\?" | sed -e "s/\?      //" | xargs svn add'

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

if [ -d "/usr/local/Caskroom" ]
then
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
    source "/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
fi


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
    alias gam="/Users/hulet/bin/gamadv-xtd3/gam"

    eval "$(/opt/homebrew/bin/brew shellenv)"
    PATH="$HOMEBREW_PREFIX/opt/grep/libexec/gnubin:$PATH"

    ## next line not needed after moving ~/.zprofile to ~/.zshenv to support screen
    #[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # This loads RVM into a shell session.
    ##PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting

    export HOMEBREW_GITHUB_API_TOKEN='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'

    # Android SDK
    PATH=${PATH}:~/bin/android-sdk-macosx/tools:~/bin/android-sdk-macosx/platform-tools

    # Fresh custom bins
    PATH=${PATH}:/usr/local/fresh-public-scripts/bin

    ;;

    Linux)
    alias du1='du -hc --max-depth 1'
    alias du1s='du -c --max-depth 1 | sort -nr'
    alias open='xdg-open'
    ;;

esac


# --- Zim Framework ---
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


# --- LOCAL OVERRIDES ---
# local config overrides all
if [[ -f $HOME/.zshrc.local ]]; then
    source $HOME/.zshrc.local
fi


# Initialize Starship (Must be at the very end)
eval "$(starship init zsh)"
