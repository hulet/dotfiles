# Install

```shell
git clone https://bitbucket.org/hulet/dotfiles && cd dotfiles && ./install.sh
```

# Notes

Bazzite comes with `brew`, `git`, and other basic dependencies already installed.

Debian Trixie and Ubuntu 24.04 do not have our basic dependencies already installed.
Install with:

```shell
apt update
apt install -y sudo
sudo apt update
sudo apt install -y build-essential curl git python3 zsh
sudo chsh -s $(which zsh) $USER
git clone https://github.com/hulet/dotfiles.git
cd dotfiles
./install
```

# Thanks

Inspired by [atomantic's dotfiles](https://github.com/atomantic/dotfiles)

Some recipes by [kitchenplan's chef-osxdefaults](https://github.com/kitchenplan/chef-osxdefaults/tree/master/recipes)

Some ideas from [ptb's Mac-OS-X-Lion-Setup](https://github.com/ptb/Mac-OS-X-Lion-Setup) and [Mathias’s dotfiles](https://mths.be/dotfiles)

