
require "yaml"
require "optparse"

require "walma-screenshot/whiteboard"
require "walma-screenshot/screenshot"
require "walma-screenshot/ui"


def read_config(path, default)
  begin
    (YAML::load_file(path))['server']
  rescue
    default
  end
end


# walma-screenshot and gnome-screenshot have similar interface here
def set_screenshot_tool(name)
  `gconftool --type string --set /apps/metacity/keybinding_commands/command_screenshot "#{ name }-screenshot"`
  `gconftool --type string --set /apps/metacity/keybinding_commands/command_window_screenshot "#{ name }-screenshot --window"`
  puts "Screenshot tool is now set to #{ name }-screenshot"
end


def main
  config_filepath = "#{ ENV["HOME"] }/.config/walma-screenshot.yml"

  options = {}
  options[:url] = read_config config_filepath, "http://walmademo.opinsys.fi"

  OptionParser.new do |opts|
    opts.banner = "Usage: walma-screenshot [options]"

    opts.on("-w", "--window", "Grab the active window instead of the entire screen") do |v|
        options[:active_window] = true
    end

    opts.on("-u", "--walma-url", "iURL of the Walma Whiteboard. Defaults to #{ options[:url]} ") do |v|
        options[:url] = v
    end

    opts.on("--activate", "Activate walma-screenshot on Print Screen button. Only for Gnome 2!") do |v|
      options[:activate_tool] = "walma"
    end

    opts.on("--deactivate", "Restore gnome-screenshot") do |v|
      options[:activate_tool] = "gnome"
    end

  end.parse!


  if options[:activate_tool]
    set_screenshot_tool options[:activate_tool]
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
