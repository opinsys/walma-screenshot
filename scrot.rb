# Initializes Ruby/GTK2, as usual.
require "gtk2"
require "tempfile"
require 'net/http'
require 'uri'
require "base64"
require "json"


def capture(full)
  data = nil
  Dir.mktmpdir do |dir|
    file_path = "#{ dir }/capture.png"
    if full
      `scrot #{ file_path }`
    else
      `scrot #{ file_path } -b -s`
    end
    data = File.open(file_path, "rb") { |f| f.read }
  end
  data
end



class Whiteboard
  def initialize(domain)
    @domain = domain
  end

  def post(data)
    base = Base64.encode64 data
    res =  Net::HTTP.post_form(URI.parse("#{ @domain }/api/create"),
      'foo' => 'bar', 'image' => base )
    res_json = JSON.parse res.body
    p res_json['url']
    "#{ @domain }#{ res_json['url'] }"
  end
end



window = Gtk::Window.new

# Specify the title and border of the window.
window.title = "Whiteboard bootstrap"
window.border_width = 10

# The program will directly end upon 'delete_event'.
window.signal_connect('delete_event') do
  Gtk.main_quit
  false
end

# We create a box to pack widgets into.  
# This is described in detail in the following section.
# The box is not really visible, it is just used as a tool to arrange 
# widgets.
box1 = Gtk::HBox.new(false, 0)

# Put the box into the main window.
window.add(box1)

# Creates a new button with the label "Button 1".
grab_fullscreen = Gtk::Button.new("Fullscreen")




whiteboard = Whiteboard.new "http://10.246.133.171:1337"

box1.pack_start(grab_fullscreen, true, true, 0)

grab_window = Gtk::Button.new("Window only")

grab_fullscreen.signal_connect( "clicked" ) do |w|
  url = whiteboard.post capture true
  `gnome-open #{ url }`
  Gtk.main_quit
end

grab_window.signal_connect("clicked") do |w|
  url = whiteboard.post capture false
  `gnome-open #{ url }`
  Gtk.main_quit
end


box1.pack_start(grab_window, true, true, 0)

# You may call the show method of each widgets, as follows:
#   button1.show
#   button2.show
#   box1.show
#   window.show 
window.show_all
Gtk.main
