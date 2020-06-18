#!/usr/bin/env bash

## with help from https://github.com/atomantic/dotfiles/blob/master/osx.sh
## and https://github.com/kitchenplan/chef-osxdefaults/tree/master/recipes


## TODO:
# disable location services: System Preferences -> Security & Privacy -> Privacy -> Enable Location Services
# disable Handoff: System Preferences -> General -> Allow Handoff ...
# disable: System Preferences -> Spotlight -> Allow Spotlight Suggestions ...

# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh

# Ask for the administrator password upfront
bot "I need you to enter your sudo password so I can install some things:"
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

bot "OK, let's roll..."


# if perl modules are needed
# sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Git' 

#####
# install homebrew
#####

running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
    action "installing homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if [[ $? != 0 ]]; then
        error "unable to install homebrew, script $0 abort!"
        exit -1
    fi
fi
ok

running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
    action "installing brew-cask"
    require_brew caskroom/cask/brew-cask
fi
ok

running "setting up taps"
brew tap homebrew/php > /dev/null 2>&1
ok

###############################################################################
#Install command-line tools using Homebrew                                    #
###############################################################################
# Make sure we’re using the latest Homebrew
running "updating homebrew"
brew update
ok


bot "installing homebrew command-line tools"


# Install GNU core utilities (those that come with OS X are outdated)
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
require_brew coreutils
#require_brew docker
require_brew dos2unix
require_brew elinks
require_brew git
#require_brew gnuplot
require_brew grep
require_brew hexedit
require_brew htop-osx
require_brew iftop
require_brew mysql
#require_brew npm
#require_brew phpunit
require_brew phpmyadmin
require_brew rename
require_brew siege
require_brew unrar
require_brew vim
require_brew wget


# npm install --global gulp

###############################################################################
# Native Apps (via brew cask)                                                 #
###############################################################################
bot "installing GUI tools via homebrew casks..."
#brew tap caskroom/versions > /dev/null 2>&1

require_cask 1password
#require_cask audacity
require_cask bettertouchtool
#require_cask chromecast
require_cask disk-inventory-x
require_cask dropbox
require_cask firefox
#require_cask filezilla
require_cask gimp
require_cask google-chrome
#require_cask handbrake
#require_cask libreoffice
#require_cask lighttable
#require_cask macgdbp
#require_cask opera
#require_cask poedit
#require_cask remote-desktop-connection
#require_cask skype
require_cask spectacle
#require_cask transmission
require_cask vagrant
require_cask virtualbox
require_cask vlc
require_cask zoomus


bot "Alright, cleaning up homebrew cache..."
# Remove outdated versions from the cellar
brew cleanup > /dev/null 2>&1
bot "All clean"


bot "brew post-install tasks"
brew services start mysql
sudo cp ./phpmyadmin.conf /private/etc/apache2/other/
sudo apachectl restart
ok


###############################################################################
bot "Configuring General System UI/UX..."
###############################################################################


################################################
bot "Standard System Changes"
################################################

running "allow 'locate' command"
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist > /dev/null 2>&1;ok

running "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2;ok

running "Always show scrollbars"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always";ok
# Possible values: `WhenScrolling`, `Automatic` and `Always`

running "Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001;ok

running "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true;ok

running "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true;ok

running "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false;ok

running "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true;ok

running "Disable Notification Center and remove the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist > /dev/null 2>&1;ok

running "Disable smart quotes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false;ok

running "Disable smart dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false;ok

###############################################################################
bot "Trackpad, mouse, keyboard, Bluetooth accessories, and input"
###############################################################################

running "Enable 'Tap to click'"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
ok

running "Enable 'Seconday click' (click or tap with two fingers)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
ok

running "Disable 'Swipe between pages'"
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -int 0;ok

running "Disable “natural” (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false;ok

running "Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3;ok

running "Use scroll gesture with the Ctrl (^) modifier key to zoom"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144;ok
running "Follow the keyboard focus while zoomed in"
defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true;ok

running "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false;ok

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/set_a_blazingly_fast_keyboard_repeat_rate.rb
running "Set a respectably fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 2;ok

running "Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false;ok

###############################################################################
bot "Configuring the Screen"
###############################################################################

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/set_screensaver_preferences.rb
running "ask for password when screen is locked"
defaults write com.apple.screensaver askForPassword -int 1;ok
running "wait 60 seconds between screensaver & lock"
defaults write com.apple.screensaver askForPasswordDelay -int 60;ok

running "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2;ok


###############################################################################
bot "Finder Configs"
###############################################################################

running "Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true;ok

running "Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv";ok

###############################################################################
bot "Dock & Dashboard"
###############################################################################

running "Set the icon size of Dock items to x pixels"
defaults write com.apple.dock tilesize -int 16;ok

running "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true;ok

running "Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true;ok

running "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false;ok

running "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true;ok

running "Make Dock more transparent"
defaults write com.apple.dock hide-mirror -bool true;ok

bot "Configuring Hot Corners"
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center

running "Bottom left screen corner → Mission Control"
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0;ok

###############################################################################
# Spotlight                                                                   #
###############################################################################

running "Change indexing order and disable some search results"
# Change indexing order and disable some search results
# Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
#   MENU_DEFINITION
#   MENU_CONVERSION
#   MENU_EXPRESSION
#   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
#   MENU_WEBSEARCH             (send search queries to Apple)
#   MENU_OTHER
defaults write com.apple.spotlight orderedItems -array \
    '{"enabled" = 1;"name" = "APPLICATIONS";}' \
    '{"enabled" = 1;"name" = "SYSTEM_PREFS";}' \
    '{"enabled" = 1;"name" = "DIRECTORIES";}' \
    '{"enabled" = 1;"name" = "PDF";}' \
    '{"enabled" = 1;"name" = "FONTS";}' \
    '{"enabled" = 1;"name" = "DOCUMENTS";}' \
    '{"enabled" = 0;"name" = "MESSAGES";}' \
    '{"enabled" = 0;"name" = "CONTACT";}' \
    '{"enabled" = 0;"name" = "EVENT_TODO";}' \
    '{"enabled" = 0;"name" = "IMAGES";}' \
    '{"enabled" = 0;"name" = "BOOKMARKS";}' \
    '{"enabled" = 0;"name" = "MUSIC";}' \
    '{"enabled" = 0;"name" = "MOVIES";}' \
    '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
    '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
    '{"enabled" = 0;"name" = "SOURCE";}' \
    '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
    '{"enabled" = 0;"name" = "MENU_OTHER";}' \
    '{"enabled" = 1;"name" = "MENU_CONVERSION";}' \
    '{"enabled" = 1;"name" = "MENU_EXPRESSION";}' \
    '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
    '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null
ok


###############################################################################
bot "Power Management"
###############################################################################

running "Don't dim the screen"
sudo pmset -a halfdim 0;ok

running "Disable Power Nap while on battery power"
sudo pmset -b darkwakes 0;ok

running "Prevent computer from sleeping automatically when the display is off"
sudo pmset -c sleep 0;ok

###############################################################################
bot "Time Machine"
###############################################################################

running "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true;ok

running "Disable local Time Machine snapshots"
sudo tmutil disablelocal;ok

###############################################################################
bot "Address Book, Dashboard, iCal, TextEdit, and Disk Utility"
###############################################################################

running "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0;ok

###############################################################################
bot "Custom settings"
###############################################################################

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/disable_resume_system-wide.rb
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx
running "Disable resume system-wide"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false;ok

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/dock_position_the_dock_on_the_left_side.rb
running "Move the Dock to the left side of the screen"
defaults write com.apple.dock orientation -string "left";ok

running "Enable dock magnification"
defaults write com.apple.dock magnification -int 1;ok

running "Set dock magnification size"
defaults write com.apple.dock largesize -float 25.77777862548828;ok

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/enable_standard_function_keys.rb
running "Use all F1, F2, etc. keys as standard function keys"
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true;ok

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/menu_add_battery_percentage.rb
running "Add battery percentage in menubar"
defaults write com.apple.menuextra.battery ShowPercent -string "YES";ok

# https://discussions.apple.com/thread/3157331?start=0&tstart=0
# http://secrets.blacktree.com/?showapp=.GlobalPreferences
running "Increasing tracking speed"
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1;ok

# http://secrets.blacktree.com/?showapp=.GlobalPreferences
running "Don't play feedback when volume is changed"
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false;ok

running "Don't ask to enable auto dictation when using function key"
defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false;ok

running "Don't ask to 'Try the new Safari' or set as default"
defaults write com.apple.Safari DefaultBrowserDateOfLastPrompt -date '2080-01-01T00:00:00Z';ok
defaults write com.apple.Safari DefaultBrowserPromptingState -int 2;ok
defaults write com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched -bool YES;ok
defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2050-01-01T00:00:00Z;ok
defaults write com.apple.coreservices.uiagent CSUILastOSVersionWhereSafariRecommendationWasMade -float 10.99;ok


running "Show volume in menu bar"
defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Volume.menu"
running "Show date in menu bar"
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"

# https://github.com/ptb/Mac-OS-X-Lion-Setup/blob/master/setup.sh
### Automatically reduce brightness before display goes to sleep
#/usr/bin/sudo /usr/bin/pmset -b halfdim 0

# https://github.com/ptb/Mac-OS-X-Lion-Setup/blob/master/setup.sh
running "Setting up Spectacle"
osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Spectacle.app" }' > /dev/null 2>&1
ok

# add Google Chrome extensions
#http://stackoverflow.com/questions/16800696/how-install-crx-chrome-extension-via-command-line
# TODO

# thanks to Orangenhain at Stack Overflow
# http://apple.stackexchange.com/questions/13598/updating-modifier-key-mappings-through-defaults-command-tool
# http://hints.macworld.com/article.php?story=20060825072451882
#It's important for the defaults command to use the correct "keyboard ID" in the key, it seems to be: com.apple.keyboard.modifiermapping.$VendorID-$ProductID-0
#
#For example the internal keyboard for my MacBook Air uses: com.apple.keyboard.modifiermapping.1452-579-0, while the external keyboard on my iMac uses com.apple.keyboard.modifiermapping.1118-219-0
#
#How to get the correct "keyboard ID"? On the command line you can use:
#
#ioreg -p IOUSB -c IOUSBDevice | grep -e class -e idVendor -e idProduct
#to get a list of your USB devices with the relevant parameters:
#
#[...]
#+-o Natural® Ergonomic Keyboard 4000@fa140000  <class IOUSBDevice, id 0x100000452, registered, matched, active, busy 0 (115 ms), retain 12>
#"idProduct" = 219
#"idVendor" = 1118
#My guess is that the third parameter (the "-0" part) is a "counter", in case you have more than one keyboard of the same type.
#
#So, to switch off the CapsLock key on my external keyboard I can now use:
#
#defaults -currentHost write -g com.apple.keyboard.modifiermapping.1118-219-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>-1</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
#And, for completeness' sake, here's a list of possible key codes to use (from Mac OS X Hints):
#
#None — –1
#Caps Lock — 0
#Shift (Left) — 1
#Control (Left) — 2
#Option (Left) — 3
#Command (Left) — 4
#Keypad 0 — 5
#Help — 6
#Shift (Right) — 9
#Control (Right) — 10
#Option (Right) — 11
#Command (Right) — 12
#
running "set caps lock to control"
VENDOR=`ioreg -p IOUSB -c IOUSBDevice | grep -i "apple internal" -A 18 | grep idVendor | cut -d'=' -f2 | tr -d ' '`
PRODUCT=`ioreg -p IOUSB -c IOUSBDevice | grep -i "apple internal" -A 18 | grep idProduct | cut -d'=' -f2 | tr -d ' '`
defaults -currentHost write -g com.apple.keyboard.modifiermapping.$VENDOR-$PRODUCT-0 -array-add '<dict><key>HIDKeyboardModifierMappingDst</key><integer>2</integer><key>HIDKeyboardModifierMappingSrc</key><integer>0</integer></dict>'
ok




