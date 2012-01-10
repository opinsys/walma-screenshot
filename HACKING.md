
# Hacking

Dependencies

    sudo apt-get install ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot git-core rdtool

Fetch the code

    git clone git://github.com/opinsys/walma-screenshot.git
    cd walma-screenshot

Running

    ruby walma-screenshot.rb

Build man pages

    make man

## Building a deb-package


Required tools

    sudo apt-get install devscripts debhelper rdtool

Build

    debuild -us -uc

Resources

http://developer.ubuntu.com/packaging/html/packaging-new-software.html
https://help.launchpad.net/Packaging/PPA/BuildingASourcePackage
http://wiki.debian.org/Packaging
