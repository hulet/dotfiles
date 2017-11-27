#!/bin/sh

# reset
brew uninstall --force phpunit
brew uninstall --force phpmyadmin
brew uninstall --force drush
brew uninstall --force php71-xdebug && rm -f /usr/local/etc/php/7.1/conf.d/ext-xdebug.ini
brew uninstall --force php71-ssh2 && rm -f /usr/local/etc/php/7.1/conf.d/ext-ssh2.ini
brew uninstall --force php71-mcrypt && rm -f /usr/local/etc/php/7.1/conf.d/ext-mcrypt.ini
brew uninstall --force php71-ioncubeloader && rm -f /usr/local/etc/php/7.1/conf.d/ext-ioncubeloader.ini
brew uninstall --force php71
brew uninstall --force curl

# install
brew install --with-openssl curl
brew install --with-httpd --with-homebrew-curl --with-thread-safety php71
brew install --with-thread-safe php71-ioncubeloader && sed -i -e 's/ioncubeloader.so/ioncubeloader_ts.so/' /usr/local/etc/php/7.1/conf.d/ext-ioncubeloader.ini
brew install --build-from-source php71-mcrypt
brew install --build-from-source php71-ssh2
brew install --build-from-source php71-xdebug
brew install drush
brew install phpmyadmin
brew install phpunit

# test
php -v
sudo apachectl restart
