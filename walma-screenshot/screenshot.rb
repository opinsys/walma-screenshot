require "tempfile"

# Bit cheating here. We'll use scrot command line tool for capturing the
# screenshots. It has pretty crappy interfaces so we have to fiddle with temp
# directories here.
class Screenshot

  attr_accessor :image

  # Scrot parameters
  FULLSCREEN = []
  WINDOW = ['-b', '-s']
  ACTIVE_WINDOW = ['-b', '-u']

  def initialize
    @max_size = 600.0
    @image = nil
  end

  def capture_fullscreen
    capture FULLSCREEN
  end

  def capture_window
    capture WINDOW
  end

  def capture_active_window
    capture ACTIVE_WINDOW
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

  def capture(scrot_params)
    Dir.mktmpdir("walma-screenshot-") do |dir|

      file_path = "#{ dir }/capture.png"

      system('scrot', file_path, *scrot_params)

      if $?.exitstatus == 0
        @image = Gtk::Image.new file_path
      elsif $?.exitstatus == 2
        # User aborted screenshot. Pressing esc etc.
        @image = nil
      else
        # TODO: show better error to user
        raise "could not call scrot"
      end

      @image
    end
  end

end
