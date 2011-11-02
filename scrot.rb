# Initializes Ruby/GTK2, as usual.
require "rubygems"
require "gtk2"
require "tempfile"
require 'net/http'
require 'uri'
require "base64"
require "json"


def capture(full)
  Dir.mktmpdir("whiteboard-screenshot") do |dir|

    file_path = "#{ dir }/capture.png"

    if full
      system('scrot', file_path)
    else
      system('scrot', file_path, '-b', '-s')
    end

    if $?.exitstatus == 0
      File.open(file_path, "rb") { |f| f.read }
    elsif $?.exitstatus == 2
      # User aborted screenshot. Pressing esc etc.
      nil
    else
      raise "could not call scrot"
    end

  end
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
whiteboard = Whiteboard.new "http://10.246.133.171:1337"

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
main_box = Gtk::VBox.new(false, 0)
window.add(main_box)
box1 = Gtk::HBox.new(true, 0)
box2 = Gtk::HBox.new(false, 0)

main_box.pack_start(box1, true, true, 5)
main_box.pack_start(box2, true, true, 5)


# Creates a new button with the label "Button 1".
grab_fullscreen = Gtk::Button.new("Fullscreen")
grab_window = Gtk::Button.new("Window only")
label = Gtk::Label.new("sdfsda")

box1.pack_start(grab_fullscreen, true, true, 0)
box1.pack_start(grab_window, true, true, 0)

box2.pack_start(label, true, true, 0)






grab_fullscreen.signal_connect( "clicked" ) do |w|
  url = whiteboard.post capture true
  system("gnome-open", url)
  Gtk.main_quit
end

grab_window.signal_connect("clicked") do |w|
  label.set_text "Click a window"
  # Small timeout allows the event loop to update label text.
  Gtk::timeout_add(50) do
    data = capture false
    next unless data
    url = whiteboard.post data
    system("gnome-open", url)
    Gtk.main_quit
    false
  end
end



# You may call the show method of each widgets, as follows:
#   button1.show
#   button2.show
#   box1.show
#   window.show 
window.show_all
Gtk.main
