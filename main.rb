#!/usr/bin/ruby

require "yaml"
require "optparse"

require "whiteboard"
require "screenshot"
require "ui"



def read_config(path, default)
  begin
    (YAML::load_file(path))['server']
  rescue
    default
  end
end


if __FILE__ == $0
  config_filepath = "#{ ENV["HOME"] }/.whiteboard.yml"


  options = {}
  options[:url] = read_config config_filepath, "https://whiteboard.opinsys.fi"

  OptionParser.new do |opts|
    opts.banner = "Usage: walma-screenshot [options]"

    opts.on("-w", "--window", "Grab the active window instead of the entire screen") do |v|
        options[:active_window] = true
    end

    opts.on("-u", "--walma-url", "URL of the Walma Whiteboard. Defaults to #{ options[:url]} ") do |v|
        options[:url] = v
    end

  end.parse!


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

