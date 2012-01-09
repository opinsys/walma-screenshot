# Screenshot tool for Walma Whiteboard

## Dependencies

    ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot

Tested with ruby 1.8 on Ubuntu 10.04.

## Installation to Ubuntu Lucid from Git

    sudo apt-get install ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot git-core
    git clone git://github.com/opinsys/walma-screenshot.git
    cd walma-screenshot
    sudo make install
    walma-screenshot --activate # Metacity only

And try hitting Print Screen :)

## Building deb-package

    debuild -us -uc

http://developer.ubuntu.com/packaging/html/packaging-new-software.html
https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage

## Configuration

Optionally you can set ~/.config/walma-screenshot.yml with a different server:

    server: http://10.0.0.7:1337

