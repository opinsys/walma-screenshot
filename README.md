# Screenshot tool for Walma Whiteboard

## Dependencies

    ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot

Tested with ruby 1.8 on Ubuntu 10.04.

## Installation to Ubuntu Lucid from Git

Dependencies

    sudo apt-get install ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot git-core rdtool

Fetch the code

    git clone git://github.com/opinsys/walma-screenshot.git
    cd walma-screenshot

Build and install it

    make
    sudo make install

Activate as default screenshot tool

    walma-screenshot --activate # Metacity only

And try hitting Print Screen :)

## Configuration

Optionally you can set ~/.config/walma-screenshot.yml with a different server:

    server: http://10.0.0.7:1337


## Building deb-package

http://developer.ubuntu.com/packaging/html/packaging-new-software.html
https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage

### Required tools

    sudo apt-get install devscripts debhelper


Man building requires `rdtool` gem.


### Build

    debuild -us -uc


