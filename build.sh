#!/bin/bash

#Ruby setup
sudo apt install ruby ruby-dev
sudo gem install compass
sudo gem install sass-css-importer --pre

# Exit the script if any command returns a non-true return value (http://www.davidpashley.com/articles/writing-robust-shell-scripts/)
set -e

# sudo apt-get install npm nodejs-legacy
# npm config set prefix ~

sudo npm install -g grunt-cli
sudo npm install -g bower
bower install
npm install
grunt prod
