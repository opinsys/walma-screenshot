
require "yaml"
require "optparse"

require "walma-screenshot/whiteboard"
require "walma-screenshot/screenshot"
require "walma-screenshot/ui"
require "walma-screenshot/gconfscreenshot"

WALMA_VERSION = "0.2.1"



def read_config(default)
  begin
    YAML::load_file("#{ ENV["HOME"] }/.config/walma-screenshot.yml")['server']
  rescue
    begin
      YAML::load_file("/etc/walma-screenshot.yml")['server']
    rescue
      default
    end
  end
end



lang = ENV['LANG'].match(/^([a-z]{2})/)[1]
if lang.nil? or lang.empty?
  $stderr.puts "Could not find language from LANG"
  lang = "en"
end

$translations = Translations.new lang.downcase

# Add translation tool to everywhere
class Object
  def _(s)
   $translations.get s
  end
end


def main


  print_screen_conf = CongiregurePrintScreen.new "walma-screenshot", "walma-screenshot --window"


  options = {}
  options[:url] = read_config "http://walmademo.opinsys.fi"

  OptionParser.new do |opts|

    opts.banner = %Q(
    Walma Screenshot is an integrated Screenshot tool for Walma Whiteboard

      Usage: walma-screenshot [options]
    )


    opts.on("-v", "--version", "") do |v|
      options[:exit] = true
      puts "Walma Screenshot #{ WALMA_VERSION }"
    end

    opts.on("-w", "--window", "Grab the active window instead of the entire screen") do |v|
        options[:active_window] = true
    end

    opts.on("-a", "--walma-address URL", "URL of the Walma Whiteboard. Defaults to #{ options[:url]} ") do |v|
        options[:url] = v
    end


    opts.on("--activate", "Activate walma-screenshot on Print Screen button") do |v|
      print_screen_conf.activate
      options[:exit] = true
    end

    opts.on("--deactivate", "Restore original screenshot tool") do |v|
      print_screen_conf.restore_system_default
      options[:exit] = true
    end

  end.parse!


  return if options[:exit]

  whiteboard = Whiteboard.new options[:url]
  ui = UI.new whiteboard, print_screen_conf

  # Capture screenshot on start up
  if options[:active_window]
    ui.capture_active_window
  else
    ui.capture_fullscreen
  end

  Gtk.main
end

if __FILE__ == $0
  main()
end
