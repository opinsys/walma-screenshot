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
    @max_size = 500.0
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

  # Returns a new Image that is made to fit in @max_size square
  def thumbnail
    return if @image.nil?

    size = [ @image.pixbuf.width.to_f, @image.pixbuf.height.to_f ]

    if size.any? { |v| v > @max_size }
      ratio = size.map { |v| @max_size / v }.min
      size = size.map { |v| (v * ratio).to_i }
    end

    Gtk::Image.new @image.pixbuf.scale( *size )
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
