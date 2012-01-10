
require "gtk2"

require "walma-screenshot/translations"


class UI


  def initialize(whiteboard, print_screen_conf)

    @screenshot = Screenshot.new
    @whiteboard = whiteboard
    @printscreen_conf = print_screen_conf

    @window = Gtk::Window.new
    @window.modal = true
    @window.resizable = false
    @window.default_width = 400
    @window.default_height = 600


    @window.title = _ "Walma Screenshot"
    @window.border_width = 10

    @window.signal_connect('delete_event') do
      Gtk.main_quit
      false
    end

    @window.signal_connect("key_press_event") do |widget, event|
      # Escape key
      if event.keyval == 65307
        Gtk.main_quit
      end
      false
    end

    @label = Gtk::Label.new

    title = Gtk::Label.new
    title.set_markup "<b><big>#{ _ "Capture" }</big></b>"

    @main_box = Gtk::VBox.new(false, 0)
    @window.add(@main_box)
    capture_buttons_box = Gtk::HBox.new(true, 0)
    @action_buttons_box = Gtk::HBox.new(true, 0)
    status = Gtk::HBox.new(false, 0)
    @image_box = Gtk::HBox.new(false, 0)



    @main_box.pack_start(title, true, true, 5)
    @main_box.pack_start(status, true, true, 5)
    @main_box.pack_start(capture_buttons_box, true, true, 5)
    @main_box.pack_start(@image_box, true, true, 5)
    @main_box.pack_start(@action_buttons_box, true, true, 5)

    @footer = Gtk::HBox.new(false, 0)
    @main_box.pack_start(@footer, true, true, 5)

    if @printscreen_conf.can_configure_current_window_manager?
      display_settings
    end


    about = create_markup_button "<small>#{ _"About Walma"  }</small>"
    about.signal_connect("clicked") do |w|
      `xdg-open http://walma.opinsys.com/about`
    end

    exit_button = create_markup_button "<small>#{ _ "Exit" }</small>"

    @footer.pack_start exit_button, false, true, 0
    @footer.pack_start about, false, true, 0


    grab_fullscreen = Gtk::Button.new _"Fullscreen"
    grab_window = Gtk::Button.new _"Window"



    capture_buttons_box.pack_start grab_fullscreen, true, true, 0
    capture_buttons_box.pack_start grab_window, true, true, 0


    status.pack_start @label, true, true, 0



    exit_button.signal_connect("clicked") do |w|
      Gtk.main_quit
    end

    grab_fullscreen.signal_connect( "clicked" ) do |w|
      capture_fullscreen
    end


    grab_window.signal_connect("clicked") do |w|
      capture_window
    end



    # You may call the show method of each widgets, as follows:
    #   button1.show
    #   button2.show
    #   capture_buttons_box.show
    #   window.show
    @window.show_all

  end


  def capture_fullscreen
    # Hide this window show that it won't show up in the screenshot. Timeout
    # allows the event loop to hide the window
    @window.hide_all

    Gtk::timeout_add(10) do

      @screenshot.capture_fullscreen

      display_thumbnail
      clear_status_text

      false
    end
  end

  def capture_active_window
    @screenshot.capture_active_window
    display_thumbnail
  end


  def capture_window
    @label.set_text _"Click on some window or select rectangle with mouse. Press esc to abort."
    # Small timeout allows the event loop to update label text.
    Gtk::timeout_add(10) do

      @screenshot.capture_window

      display_thumbnail
      clear_status_text

      false
    end
  end




  def display_action_buttons

    if @action_buttons_visible or @screenshot.image.nil?
      return
    end

    @save_button = Gtk::Button.new _"Save as..."
    @open_in_whiteboard_button = Gtk::Button.new _"Open in Walma"

    @open_in_whiteboard_button.signal_connect("clicked") do |w|
      open_screenshot_in_whiteboard
    end

    @save_button.signal_connect("clicked") do |w|
      dialog = Gtk::FileChooserDialog.new(_("Choose file"),
                                     @window,
                                     Gtk::FileChooser::ACTION_SAVE,
                                     nil,
                                     [_("Cancel"), Gtk::Dialog::RESPONSE_CANCEL],
                                     [_("Save"), Gtk::Dialog::RESPONSE_ACCEPT])

      dialog.filter = Gtk::FileFilter.new
      dialog.do_overwrite_confirmation = true
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

    @action_buttons_box.pack_start @open_in_whiteboard_button, true, true, 0
    @action_buttons_box.pack_start @save_button, true, true, 0

    @window.show_all

    @action_buttons_visible = true
  end

  def display_settings


    toggle_active = Gtk::CheckButton.new
    toggle_active.add create_label "<small>#{ _"Use from Print Screen button" }</small>"
    toggle_active.active = @printscreen_conf.active?
    toggle_active.signal_connect "toggled" do
      begin
        if toggle_active.active?
          @printscreen_conf.activate
        else
          @printscreen_conf.restore_system_default
        end
      rescue PrintScreenConfigureFailed
        set_error_text _"Failed to configure Print Screen button"
      end
    end


    @footer.pack_start toggle_active, true, true, 0


  end


  def save_image(path)
    set_status_text _("Saving image to") + " " +path

    Gtk::timeout_add(10) do

      begin
        File.open(path, 'w') {|f| f.write(@screenshot.png_buffer) }
      rescue
        set_error_text $!.message
        next
      end

      Gtk.main_quit

      false
    end
  end


  def open_screenshot_in_whiteboard
    set_status_text _"Opening screenshot in web browser..."
    Gtk::timeout_add(10) do

      begin
        url = @whiteboard.post @screenshot.png_buffer
      rescue WhiteboardError
        set_error_text $!.message
        next
      end

      system("xdg-open", url)
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

      display_action_buttons
      @window.show_all
      @window.set_focus @open_in_whiteboard_button
    end
  end


  def set_error_text(msg)
    @label.set_text "ERROR: #{ msg }"
  end

  def set_status_text(msg)
    @label.set_text msg
  end

  def clear_status_text
    set_status_text ""
  end

  private

  def create_label(markup)
    label = Gtk::Label.new
    label.set_markup markup
    label
  end

  def create_markup_button(markup)
    button = Gtk::Button.new
    button.add create_label markup
    button
  end

end
