# Initializes Ruby/GTK2, as usual.
require "rubygems"
require "gtk2"
require "tempfile"
require 'net/http'
require 'net/https'
require 'uri'
require "base64"
require "json"
require "yaml"


# Bit cheating here. We'll use scrot command line tool for capturing the
# screenshots. It has pretty crappy interfaces so we have to fiddle with temp
# directories here.
def capture(fullscreen)
  Dir.mktmpdir("whiteboard-screenshot") do |dir|

    file_path = "#{ dir }/capture.png"

    if fullscreen
      system('scrot', file_path)
    else
      # Single window only
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
    @url = URI.parse "#{ domain }/api/create"
  end

  def post(data)
    base = Base64.encode64 data
    req = Net::HTTP::Post.new(@url.path)
    req.set_form_data( 'image' => base )
    http = Net::HTTP.new(@url.host, @url.port)

    if @url.port == 443
      http.use_ssl = true
    end

    p "posting to #{ @domain }"
    res = http.start {|http| http.request(req) }
    p "done"
    case res
    when Net::HTTPSuccess
      res_json = JSON.parse res.body
      p res_json['url']
      "#{ @domain }#{ res_json['url'] }"
    else
      # TODO: Show nice error to user
      raise "Failed to post"
    end
  end
end




class UI

  def initialize(whiteboard)
    window = Gtk::Window.new

    # Specify the title and border of the window.
    window.title = "Whiteboard bootstrap"
    window.border_width = 10

    # The program will directly end upon 'delete_event'.
    window.signal_connect('delete_event') do
      Gtk.main_quit
      false
    end

    @whiteboard = whiteboard
    main_box = Gtk::VBox.new(false, 0)
    window.add(main_box)
    box1 = Gtk::HBox.new(true, 0)
    box2 = Gtk::HBox.new(false, 0)
    box3 = Gtk::HBox.new(false, 0)

    main_box.pack_start(box1, true, true, 5)
    main_box.pack_start(box2, true, true, 5)
    main_box.pack_start(box3, true, true, 5)

    # Creates a new button with the label "Button 1".
    grab_fullscreen = Gtk::Button.new "Fullscreen"
    grab_window = Gtk::Button.new "Window only"
    exit_button = Gtk::Button.new "Exit"

    @label_text = "Open screenshot in whiteboard"
    @label = Gtk::Label.new @label_text

    box1.pack_start grab_fullscreen, true, true, 0
    box1.pack_start grab_window, true, true, 0
    box2.pack_start @label, true, true, 0
    box3.pack_start exit_button, true, true, 0


    exit_button.signal_connect("clicked") do |w|
      Gtk.main_quit
    end

    grab_fullscreen.signal_connect( "clicked" ) do |w|
      window.hide_all
      Gtk::timeout_add(10) do

        begin
          url = @whiteboard.post capture true
        rescue SystemCallError
          show_error
        else
          open_and_quit url
        ensure
          window.show_all
        end

        false
      end
    end

    grab_window.signal_connect("clicked") do |w|
      @label.set_text "Click on some window. Press esc to abort."
      # Small timeout allows the event loop to update label text.
      Gtk::timeout_add(50) do
        data = capture false

        if not data
          @label.set_text @label_text
          next
        end

        begin
          url = @whiteboard.post data
        rescue SystemCallError
          show_error
        else
          open_and_quit url
        end
        false
      end
    end

    # You may call the show method of each widgets, as follows:
    #   button1.show
    #   button2.show
    #   box1.show
    #   window.show 
    window.show_all

  end

  def show_error
    msg = $!
    @label.set_text "ERROR: #{ msg }"
  end

  def open_and_quit(url)
    @label.set_text "Opening screenshot in the browser"
    system("gnome-open", url)

    Gtk::timeout_add(2000) do
      Gtk.main_quit
      false
    end
  end

end


def read_config(path, default)
  return default unless File.exist? path
  File.open(path, "r") do |f|
    config = YAML::load f.read
    if config["server"]
      config["server"]
    else
      default
    end
  end
end


if __FILE__ == $0
  config_filepath = "#{ ENV["HOME"] }/.whiteboard.yml"

  domain = read_config config_filepath, "https://whiteboard.opinsys.fi"

  whiteboard = Whiteboard.new domain
  ui = UI.new whiteboard
  Gtk.main
end

