# Screenshot tool for Walma Whiteboard

Walma Screenshot is a helper tool for [Walma
Whiteboard](http://walma.opinsys.fi). It acts as replacement for
gnome-screenshot in Gnome 2 environments. It replicates the functionality and
adds an option for opening the screenshot directly in Walma Whiteboard.

It currently works best in Gnome 2 environments, but should work in others too.
You just have map Print Screen button manually.

## Dependencies

    ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot

Tested with ruby 1.8 on Ubuntu 10.04.

## Installation

### Ubuntu Package

See [Downloads](https://github.com/opinsys/walma-screenshot/downloads)

### From source (not recommended)

Dependencies

    sudo apt-get install ruby libgtk2-ruby libjson-ruby libopenssl-ruby scrot git-core rdtool

Fetch the code

    git clone git://github.com/opinsys/walma-screenshot.git
    cd walma-screenshot

Build and install it

    make
    sudo make install

Run

    walma-screenshot


## Configuration

You can manually configure Walma Whiteboard server in

    /etc/walma-screenshot.yml

For system wide configuration and for per user in

    ~/.config/walma-screenshot.yml

The syntax is following

    server: <server address>

Example

    server: http://walma.example.com

# Copyright

Copyright © 2010 Opinsys Oy

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA 02110-1301, USA.

