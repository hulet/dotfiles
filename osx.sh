#!/usr/bin/env bash

## with help from https://github.com/atomantic/dotfiles/blob/master/osx.sh
## and https://github.com/kitchenplan/chef-osxdefaults/tree/master/recipes


## TODO:
# disable location services: System Preferences -> Security & Privacy -> Privacy -> Enable Location Services
# disable Handoff: System Preferences -> General -> Allow Handoff ...
# customize Terminal settings (font size 18, disable Audible bell)
#
#
# Set mouse shortcuts
# System Settings -> Desktop & Dock -> Shortcuts... -> Mission Control Mouse Shortcut -> Mouse Button 5


# if perl modules are needed
# sudo PERL_MM_USE_DEFAULT=1 perl -MCPAN -e 'install Git' 


# Install GNU core utilities (those that come with OS X are outdated)
#require_brew docker
#require_brew git-lfs
#require_brew grep


#### For Java:
# brew install openjdk@11
# sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk
#
# add to startup file: 
# export JAVA_HOME=`/usr/libexec/java_home`


# npm install --global gulp



###############################################################################
echo " --> Configuring General System UI/UX..."
###############################################################################


################################################
echo " --> Standard System Changes"
################################################

echo " --> allow 'locate' command"
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist > /dev/null 2>&1

echo " --> Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

echo " --> Always show scrollbars"
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
# Possible values: `WhenScrolling`, `Automatic` and `Always`

echo " --> Increase window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo " --> Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

echo " --> Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

echo " --> Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo " --> Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

echo " --> Disable smart quotes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo " --> Disable smart dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

###############################################################################
echo " --> Trackpad, mouse, keyboard, Bluetooth accessories, and input"
###############################################################################

echo " --> Enable 'Tap to click'"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo " --> Enable 'Seconday click' (click or tap with two fingers)"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

echo " --> Disable 'Swipe between pages'"
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -int 0

echo " --> Disable 'natural' (Lion-style) scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo " --> Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo " --> Use scroll gesture with the Ctrl (^) modifier key to zoom"
sudo defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

echo " --> Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/set_a_blazingly_fast_keyboard_repeat_rate.rb
echo " --> Set a respectably fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 2

echo " --> Disable auto-correct and related"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticInlinePredictionEnabled -bool false

echo " --> Disable auto period"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

echo " --> Set mouse speed"
defaults write NSGlobalDomain com.apple.mouse.scaling 3


###############################################################################
echo " --> Configuring the Screen"
###############################################################################

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/set_screensaver_preferences.rb
echo " --> ask for password when screen is locked"
defaults write com.apple.screensaver askForPassword -int 1
echo " --> wait 60 seconds between screensaver & lock"
defaults write com.apple.screensaver askForPasswordDelay -int 60

echo " --> Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 2


###############################################################################
echo " --> Finder Configs"
###############################################################################

echo " --> Avoid creating .DS_Store files on network volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

echo " --> Use list view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `Flwv`
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

###############################################################################
echo " --> Dock & Dashboard"
###############################################################################

echo " --> Set the icon size of Dock items to x pixels"
defaults write com.apple.dock tilesize -int 16

echo " --> Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

echo " --> Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true

echo " --> Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

echo " --> Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

echo " --> Make Dock more transparent"
defaults write com.apple.dock hide-mirror -bool true

echo " --> Configuring Hot Corners"
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

echo " --> Bottom left screen corner → Mission Control"
defaults write com.apple.dock wvous-bl-corner -int 2
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Spotlight                                                                   #
###############################################################################

echo " --> Change indexing order and disable some search results"
# Change indexing order and disable some search results
# Yosemite-specific search results (remove them if your are using OS X 10.9 or older):
#   MENU_DEFINITION
#   MENU_CONVERSION
#   MENU_EXPRESSION
#   MENU_SPOTLIGHT_SUGGESTIONS (send search queries to Apple)
#   MENU_WEBSEARCH             (send search queries to Apple)
#   MENU_OTHER
defaults write com.apple.spotlight orderedItems -array \
    '{ enabled = 1; name = APPLICATIONS; },' \
    '{ enabled = 1; name = "MENU_EXPRESSION"; },' \
    '{ enabled = 0; name = CONTACT; },' \
    '{ enabled = 1; name = "MENU_CONVERSION"; },' \
    '{ enabled = 1; name = "MENU_DEFINITION"; },' \
    '{ enabled = 1; name = DOCUMENTS; },' \
    '{ enabled = 0; name = "EVENT_TODO"; },' \
    '{ enabled = 1; name = DIRECTORIES; },' \
    '{ enabled = 1; name = FONTS; },' \
    '{ enabled = 0; name = IMAGES; },' \
    '{ enabled = 0; name = MESSAGES; },' \
    '{ enabled = 1; name = MOVIES; },' \
    '{ enabled = 1; name = MUSIC; },' \
    '{ enabled = 1; name = "MENU_OTHER"; },' \
    '{ enabled = 1; name = PDF; },' \
    '{ enabled = 0; name = PRESENTATIONS; },' \
    '{ enabled = 0; name = "MENU_SPOTLIGHT_SUGGESTIONS"; },' \
    '{ enabled = 0; name = SPREADSHEETS; },' \
    '{ enabled = 1; name = "SYSTEM_PREFS"; },' \
    '{ enabled = 1; name = TIPS; },' \
    '{ enabled = 0; name = BOOKMARKS; }'

# Load new settings before rebuilding the index
killall mds > /dev/null 2>&1
# Make sure indexing is enabled for the main volume
sudo mdutil -i on / > /dev/null
# Rebuild the index from scratch
sudo mdutil -E / > /dev/null


###############################################################################
echo " --> Power Management"
###############################################################################

echo " --> Don't dim the screen"
sudo pmset -a halfdim 0

echo " --> Disable Power Nap while on battery power"
sudo pmset -b darkwakes 0

echo " --> Prevent computer from sleeping automatically when the display is off"
sudo pmset -c sleep 0

###############################################################################
echo " --> Time Machine"
###############################################################################

echo " --> Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
echo " --> Address Book, Dashboard, iCal, TextEdit, and Disk Utility"
###############################################################################

echo " --> Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0

###############################################################################
echo " --> Custom settings"
###############################################################################

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/disable_resume_system-wide.rb
# https://github.com/mathiasbynens/dotfiles/blob/master/.osx
echo " --> Disable resume system-wide"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/dock_position_the_dock_on_the_left_side.rb
echo " --> Move the Dock to the left side of the screen"
defaults write com.apple.dock orientation -string "left"

echo " --> Enable dock magnification"
defaults write com.apple.dock magnification -int 1

echo " --> Set dock magnification size"
defaults write com.apple.dock largesize -float 25.77777862548828

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/enable_standard_function_keys.rb
echo " --> Use all F1, F2, etc. keys as standard function keys"
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# https://github.com/kitchenplan/chef-osxdefaults/blob/master/recipes/menu_add_battery_percentage.rb
echo " --> Add battery percentage in menubar"
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

echo " --> lower Alert volume"
defaults write NSGlobalDomain com.apple.sound.beep.volume -float 0.50

# https://discussions.apple.com/thread/3157331?start=0&tstart=0
# http://secrets.blacktree.com/?showapp=.GlobalPreferences
echo " --> Increasing tracking speed"
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1

# http://secrets.blacktree.com/?showapp=.GlobalPreferences
echo " --> Don't play feedback when volume is changed"
defaults write NSGlobalDomain com.apple.sound.beep.feedback -bool false

echo " --> Don't ask to enable auto dictation when using function key"
defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false

echo " --> Don't ask to 'Try the new Safari' or set as default"
#defaults write com.apple.Safari DefaultBrowserDateOfLastPrompt -date '2080-01-01T00:00:00Z'
#defaults write com.apple.Safari DefaultBrowserPromptingState -int 2
defaults write com.apple.coreservices.uiagent CSUIHasSafariBeenLaunched -bool YES
defaults write com.apple.coreservices.uiagent CSUIRecommendSafariNextNotificationDate -date 2050-01-01T00:00:00Z
defaults write com.apple.coreservices.uiagent CSUILastOSVersionWhereSafariRecommendationWasMade -float 10.99

echo " --> Don't autoplay App Store videos"
defaults write com.apple.AppStore AutoPlayVideoSetting -bool false
defaults write com.apple.AppStore UserSetAutoPlayVideoSetting -bool true

#echo "Show volume in menu bar"
# TODO: not working; System Settings -> Control Center -> Sound -> Always Show in Menu Bar
#defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/Volume.menu"
echo " --> Show date in menu bar"
defaults write com.apple.menuextra.clock DateFormat -string "EEE MMM d  h:mm a"

# https://github.com/ptb/Mac-OS-X-Lion-Setup/blob/master/setup.sh
### Automatically reduce brightness before display goes to sleep
#/usr/bin/sudo /usr/bin/pmset -b halfdim 0

# https://github.com/ptb/Mac-OS-X-Lion-Setup/blob/master/setup.sh
echo " --> Setting up Rectangle"
osascript -e 'tell application "System Events" to make new login item at end of login items with properties { path: "/Applications/Rectangle.app" }' > /dev/null 2>&1

echo " --> Dark Mode, please"
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# add Google Chrome extensions
#http://stackoverflow.com/questions/16800696/how-install-crx-chrome-extension-via-command-line
# TODO

# thanks to https://stackoverflow.com/a/46460200
# and https://developer.apple.com/library/archive/technotes/tn2450/_index.html#//apple_ref/doc/uid/DTS40017618-CH1-KEY_TABLE_USAGES
echo " --> set caps lock to control"
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}'

echo " --> Proper calendars start the week on Monday"
defaults write NSGlobalDomain AppleFirstWeekday -dict gregorian 2

echo " --> Woot! All done."
echo " --> You may need to reboot for some settings to take effect."
