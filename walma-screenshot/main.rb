
require "yaml"
require "optparse"

require "walma-screenshot/whiteboard"
require "walma-screenshot/screenshot"
require "walma-screenshot/ui"
require "walma-screenshot/gconfscreenshot"


def read_config(path, default)
  begin
    (YAML::load_file(path))['server']
  rescue
    default
  end
end


# walma-screenshot and gnome-screenshot have similar interface here
def set_screenshot_tool_for_metacity(name)
  `gconftool --type string --set /apps/metacity/keybinding_commands/command_screenshot "#{ name }-screenshot"`
  `gconftool --type string --set /apps/metacity/keybinding_commands/command_window_screenshot "#{ name }-screenshot --window"`
  puts "Screenshot tool is now set to #{ name }-screenshot"
end




# I won't a price for this language detection
if ENV["LANG"].match /fi/
  $translations = Translations.new "fi"
else
  $translations = Translations.new "en"
end

# Add translation tool to everywhere
class Object
  def _(s)
   $translations.get s
  end
end


def main

  config_filepath = "#{ ENV["HOME"] }/.config/walma-screenshot.yml"
  screenshot_conf = GConfScreenshot.new "walma-screenshot", "walma-screenshot --window"


  options = {}
  options[:url] = read_config config_filepath, "http://walmademo.opinsys.fi"

  OptionParser.new do |opts|
    opts.banner = "Usage: walma-screenshot [options]"

    opts.on("-w", "--window", "Grab the active window instead of the entire screen") do |v|
        options[:active_window] = true
    end

    opts.on("-a", "--walma-address URL", "URL of the Walma Whiteboard. Defaults to #{ options[:url]} ") do |v|
        options[:url] = v
    end

    opts.on("--activate", "Activate walma-screenshot on Print Screen button. Only for Gnome 2!") do |v|
      options[:activate] = true
    end

    opts.on("--deactivate", "Restore gnome-screenshot") do |v|
      options[:deactivate] = true
    end

  end.parse!


  if options[:activate]
    screenshot_conf.activate
    return
  end

  if options[:deactivate]
    screenshot_conf.restore_gnome
    return
  end

  whiteboard = Whiteboard.new options[:url]
  ui = UI.new whiteboard

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
