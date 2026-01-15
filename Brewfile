# vim: set ft=ruby :

puts "--> Brewfile begins"

#######################################
# Universal
#

# shell core
brew "fzf"
brew "neovim"
brew "zimfw"
brew "tree-sitter-cli"

# bluefin-cli https://docs.projectbluefin.io/command-line/
brew "bat"
brew "eza"
brew "fd"
brew "ripgrep"
brew "starship"

# classic tools
brew "rename"
brew "htop"
brew "hexedit"
brew "fdupes"
brew "lazygit"
brew "dos2unix"
brew "exiftool"
brew "iftop"
brew "wget"
brew "btop"

if OS.mac?

  #######################################
  # all macOS
  #
  puts "--> Brewfile detected macOS"
  brew "ansible"
  brew "coreutils"
  brew "telnet"
  brew "yt-dlp"

  cask "1password"
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
  cask "rectangle"
  cask "tailscale-app"
  cask "visual-studio-code"
  cask "vlc"

  if `hostname`.include?("AA")

    #######################################
    # work laptop
    #
    puts "--> Brewfile detected macOS - work"

    cask "dropbox"
    cask "zoom"

  else

    #######################################
    # personal laptop
    #
    puts "--> Brewfile detected macOS - home"

    cask "handbrake-app"
    cask "mullvad-vpn"
    cask "steam"
    cask "transmission"
  end

elsif OS.linux?

  #######################################
  # all linux
  #
  puts "--> Brewfile detected linux"
  # Helper: Detect if we are in a headless environment
  # Returns true if NO desktop environment is detected
  is_headless = ENV['XDG_CURRENT_DESKTOP'].to_s.empty? && ENV['DISPLAY'].to_s.empty?

  if is_headless

    #######################################
    # headless linux
    #
    puts "--> Brewfile detected linux - server"

  else

    #######################################
    # desktop linux
    #
    puts "--> Brewfile detected linux - desktop"
  end

end

