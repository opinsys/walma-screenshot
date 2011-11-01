require "rubygems"
require 'gtk2'
require 'net/http'
require 'uri'
require "base64"
require "json"




p Gdk::screen_width
p Gdk::screen_height
p Gdk::Pixbuf::COLORSPACE_RGB
p Gdk::Display.default.n_screens



#   p "click"
#  p w
# end



# Gdk::Window.foreign_new Gdk::Screen.default().window_stack[3]

domain = "http://10.246.133.171:1337"

# buf = Gdk::Pixbuf.new Gdk::Pixbuf::COLORSPACE_RGB, true, 8, Gdk::screen_width, Gdk::screen_height
# Gdk::Pixbuf.from_drawable Gdk::Colormap.system, Gdk::Window.default_root_window, 0, 0, Gdk::screen_width, Gdk::screen_height, dest=buf

def capture(drawable)
  width = drawable.size[0]
  height =  drawable.size[1]

  buf = Gdk::Pixbuf.new Gdk::Pixbuf::COLORSPACE_RGB, true, 8, width, height
  Gdk::Pixbuf.from_drawable Gdk::Colormap.system, drawable, 0, 0, width, height, dest=buf
  png = buf.save_to_buffer("png")

end


# Gdk::Window.default_root_window.signal_connect("click") do |w|
# png = capture Gdk::Window.default_root_window

require 'ruby-debug/completion'; debugger
png = capture Gdk::Screen.default().window_stack[6]

base = Base64.encode64(png)

res =  Net::HTTP.post_form(URI.parse("#{ domain }/api/create"),
  'foo' => 'bar', 'image' => base )


res_json = JSON.parse res.body
`gnome-open #{ domain }#{ res_json['url'] }`


buf.save "foo.png", "png"
buf.save_to_buffer "png"
