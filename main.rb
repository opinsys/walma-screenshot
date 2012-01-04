#!/usr/bin/ruby

require "yaml"

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

  domain = read_config config_filepath, "https://whiteboard.opinsys.fi"

  whiteboard = Whiteboard.new domain
  ui = UI.new whiteboard

  # Capture screenshot on start up
  ui.capture_fullscreen
  Gtk.main
end

