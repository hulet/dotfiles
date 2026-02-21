# vim: set ft=ruby :
#
# Some helpful brew commands:
# brew uses --installed <package>

puts "--> Brewfile begins"

#######################################
# Universal
#

# shell core
brew "fzf"
brew "neovim"
brew "node"
brew "tree-sitter-cli"
brew "zimfw"
brew "zsh"

# bluefin-cli https://docs.projectbluefin.io/command-line/
brew "bat"
brew "eza"
brew "fd"
brew "ripgrep"
brew "starship"
brew "tealdeer"
brew "zoxide"

# Classic Tools
brew "btop"
brew "dos2unix"
brew "exiftool"
brew "fastfetch"
brew "fdupes"
brew "hexedit"
brew "htop"
brew "iftop"
brew "lazygit"
brew "rename"

if OS.mac?

  #######################################
  # All macOS
  #
  puts "--> Brewfile detected macOS"
  brew "ansible"
  brew "coreutils"
  brew "nmap"
  brew "pipx"
  brew "telnet"
  brew "wget" # linux brew wget depends on util-linux, which we may not want (and which conflicts with "rename")
  brew "yt-dlp"
  # TODO: pipx install pdf-to-scan

  cask "1password"
  cask "audacity"
  cask "balenaetcher"
  cask "brave-browser"
  cask "firefox"
  cask "ghostty"
  cask "gimp"
  cask "google-chrome"
  cask "mp3tag"
  cask "netspot"
  cask "orion"
  cask "prusaslicer"
  cask "raspberry-pi-imager"
  cask "rectangle"
  cask "tailscale-app"
  cask "visual-studio-code"
  cask "vlc"

  if `hostname`.include?("AA")

    #######################################
    # Work Laptop
    #
    puts "--> Brewfile detected macOS - work"

    tap "hashicorp/tap"
    tap "cloudflare/cloudflare"

    brew "hashicorp/tap/terraform"
    brew "cloudflare/cloudflare/cf-terraforming"
    # TODO: pipx install gam7

    cask "adobe-acrobat-reader"
    cask "dropbox"
    cask "gcloud-cli"
    cask "google-drive"
    cask "windows-app"
    cask "wireshark-app"
    cask "zoom"

  else

    #######################################
    # Personal Laptop
    #
    puts "--> Brewfile detected macOS - home"

    cask "handbrake-app"
    cask "mullvad-vpn"
    cask "steam"
    cask "transmission"

  end

elsif OS.linux?

  #######################################
  # All Linux
  #
  puts "--> Brewfile detected linux"

  # if we install vim, install exuberant-ctags as well

  # Helper: Detect if we are in a headless environment
  # Returns true if NO desktop environment is detected
  is_headless = ENV['XDG_CURRENT_DESKTOP'].to_s.empty? && ENV['DISPLAY'].to_s.empty?

  if is_headless

    #######################################
    # Headless Linux
    #
    puts "--> Brewfile detected linux - server"

    brew "zellij" # `screen` replacement

  else

    #######################################
    # Desktop Linux
    #
    puts "--> Brewfile detected linux - desktop"

    flatpak "com.brave.Browser"
    flatpak "com.prusa3d.PrusaSlicer"
    flatpak "org.gimp.GIMP"
    flatpak "org.videolan.VLC"

    # Manually Installed:
    # Cider (Apple Music player, "installed" via Gear Lever)
    # Ghostty (follow instructions on website; waiting for flatpak release)
    #
    # GNOME Extensions:
    # Media Controls (by sakithb)
    # PaperWM

  end

end

