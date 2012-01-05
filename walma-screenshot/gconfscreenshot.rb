

# Simple class for managing active screenshot tool for Metacity
class GConfScreenshot

  def initialize(fullscreen_cmd, window_cmd)
    @fullscreen_cmd = fullscreen_cmd
    @window_cmd = window_cmd
  end

  def activate
    set_tool @fullscreen_cmd, @window_cmd
  end

  def restore_gnome
    set_tool "gnome-screenshot", "gnome-screenshot --window"
  end

  def active?
    @fullscreen_cmd == current_fullscreen_cmd and
      @window_cmd == current_window_cmd
  end


  private

  def set_tool(fullscreen, window)
    `gconftool --type string --set /apps/metacity/keybinding_commands/command_screenshot "#{ fullscreen }"`
    `gconftool --type string --set /apps/metacity/keybinding_commands/command_window_screenshot "#{ window }"`
  end

  def current_fullscreen_cmd
    `gconftool --get /apps/metacity/keybinding_commands/command_screenshot`.strip
  end

  def current_window_cmd
    `gconftool --get /apps/metacity/keybinding_commands/command_window_screenshot`.strip
  end


end
