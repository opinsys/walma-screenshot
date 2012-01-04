#!/usr/bin/ruby

# Initializes Ruby/GTK2, as usual.
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
class Screenshot

  attr_accessor :image

  def initialize
    @max_size = 600.0
    @image = nil
  end

  def capture_fullscreen
    capture true
  end

  def capture_window
    capture false
  end

  def capture_active_window
    throw "not implemented"
  end

  def png_buffer
    @image.pixbuf.save_to_buffer "png"
  end

  def thumbnail
    return if @image.nil?

    width, height = @image.pixbuf.width.to_f, @image.pixbuf.height.to_f

    ratio = [ @max_size / width, @max_size / height].min

    Gtk::Image.new @image.pixbuf.scale( (width * ratio).to_i, (height * ratio).to_i )
  end

  private

  def capture(fullscreen)
    Dir.mktmpdir("whiteboard-screenshot-") do |dir|

      file_path = "#{ dir }/capture.png"

      if fullscreen
        system('scrot', file_path)
      else
        # Single window only
        system('scrot', file_path, '-b', '-s')
      end

      if $?.exitstatus == 0
        # File.open(file_path, "rb") { |f| f.read }
        # Gdk::Pixbuf.new file_path
        @image = Gtk::Image.new file_path
      elsif $?.exitstatus == 2
        # User aborted screenshot. Pressing esc etc.
        @image = nil
      else
        raise "could not call scrot"
      end

      @image
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
      # TODO: Tell more about the error to user
      set_error_text "Something failed while posting to whiteboard"
    end
  end
end




class UI

  def initialize(whiteboard)

    @screenshot = Screenshot.new
    @whiteboard = whiteboard

    @window = Gtk::Window.new

    # Specify the title and border of the window.
    @window.title = "Whiteboard bootstrap"
    @window.border_width = 10

    # The program will directly end upon 'delete_event'.
    @window.signal_connect('delete_event') do
      Gtk.main_quit
      false
    end

    @label_text = "Open screenshot in whiteboard"
    @label = Gtk::Label.new @label_text

    main_box = Gtk::VBox.new(false, 0)
    @window.add(main_box)
    capture_buttons_box = Gtk::HBox.new(true, 0)
    @action_buttons_box = Gtk::HBox.new(true, 0)
    label_box = Gtk::HBox.new(false, 0)
    exit_button_box = Gtk::HBox.new(false, 0)
    @image_box = Gtk::HBox.new(false, 0)

    main_box.pack_start(capture_buttons_box, true, true, 5)
    main_box.pack_start(label_box, true, true, 5)
    main_box.pack_start(@image_box, true, true, 5)
    main_box.pack_start(@action_buttons_box, true, true, 5)
    main_box.pack_start(exit_button_box, true, true, 5)


    grab_fullscreen = Gtk::Button.new "Fullscreen"
    grab_window = Gtk::Button.new "Window only"


    exit_button = Gtk::Button.new "Exit"


    capture_buttons_box.pack_start grab_fullscreen, true, true, 0
    capture_buttons_box.pack_start grab_window, true, true, 0


    label_box.pack_start @label, true, true, 0
    exit_button_box.pack_start exit_button, true, true, 0


    exit_button.signal_connect("clicked") do |w|
      Gtk.main_quit
    end

    grab_fullscreen.signal_connect( "clicked" ) do |w|

      # Hide this window show that it won't show up in the screenshot. Timeout
      # allows the event loop to hide the window
      @window.hide_all

      Gtk::timeout_add(10) do

        @screenshot.capture_fullscreen

        display_thumbnail

        false
      end
    end


    grab_window.signal_connect("clicked") do |w|
      @label.set_text "Click on some window. Press esc to abort."
      # Small timeout allows the event loop to update label text.
      Gtk::timeout_add(10) do

        @screenshot.capture_window

        display_thumbnail

        false
      end
    end

    # You may call the show method of each widgets, as follows:
    #   button1.show
    #   button2.show
    #   capture_buttons_box.show
    #   window.show
    @window.show_all

  end

  def display_action_buttons

    if @action_buttons_visible or @screenshot.image.nil?
      return
    end

    save_button = Gtk::Button.new "Save"
    open_in_whiteboard_button = Gtk::Button.new "Open in Walma"

    open_in_whiteboard_button.signal_connect("clicked") do |w|
      open_screenshot_in_whiteboard
    end

    save_button.signal_connect("clicked") do |w|
      dialog = Gtk::FileChooserDialog.new("Open File",
                                     @window,
                                     Gtk::FileChooser::ACTION_SAVE,
                                     nil,
                                     [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                     [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_ACCEPT])

      dialog.filter = Gtk::FileFilter.new
      dialog.filter.add_pattern "*.png"


      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        if dialog.filename.match /\.png$/
          filepath = dialog.filename
        else
          filepath = dialog.filename + ".png"
        end
      end

      dialog.destroy

      if filepath
        save_image filepath
      end

    end

    @action_buttons_box.pack_start open_in_whiteboard_button, true, true, 0
    @action_buttons_box.pack_start save_button, true, true, 0

    @window.show_all

    @action_buttons_visible = true
  end

  def save_image(path)
    set_status_text "Saving image to #{ path }"

    Gtk::timeout_add(10) do

      begin
        File.open(path, 'w') {|f| f.write(@screenshot.png_buffer) }
      rescue
        set_error_text $!.message
        next
      end

      set_status_text "Image was saved to #{ path }. Exiting..."

      Gtk::timeout_add(2000) do
        Gtk.main_quit
        false
      end

      false
    end
  end


  def open_screenshot_in_whiteboard
    set_status_text "Opening screenshot in web browser..."
    Gtk::timeout_add(10) do

      begin
        url = @whiteboard.post @screenshot.png_buffer
      rescue SystemCallError
        set_error_text $!.message
        next
      end

      system("gnome-open", url)
      Gtk::timeout_add(2000) do
        Gtk.main_quit
        false
      end

      false
    end

  end

  def display_thumbnail
    if @screenshot.image

      @image_box.each do |child|
        @image_box.remove child
      end

      @image_box.pack_start @screenshot.thumbnail, true, true, 0

      @window.show_all
    end

    display_action_buttons

  end

  def set_error_text(msg)
    @label.set_text "ERROR: #{ msg }"
  end

  def set_status_text(msg)
    @label.set_text msg
  end

end


def read_config(path, default)
  begin
    (YAML::load_file(path))['server']
  rescue
    default
  end
end


if __FILE__ == $0
  config_filepath = "#{ ENV["HOME"] }/.whiteboard.yml"

  domain = read_config config_filepath, "https://whiteboard.opinsys.fi"

  whiteboard = Whiteboard.new domain
  ui = UI.new whiteboard
  Gtk.main
end

