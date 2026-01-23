# fix 
# warning: completion was already initialized before completion module. Will call compinit again. See https://github.com/zimfw/zimfw/wiki/Troubleshooting#completion-is-not-working
# on Podman Ubuntu containers
# which calls compinit in /etc/zsh/zshrc
skip_global_compinit=1
