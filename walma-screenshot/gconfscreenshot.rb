
class PrintScreenConfigureFailed < StandardError; end

# Simple class for managing active screenshot tool for Metacity
class ConfigurePrintScreen

  def initialize(fullscreen_cmd, window_cmd)
    @fullscreen_cmd = fullscreen_cmd
    @window_cmd = window_cmd
  end

  def activate
    set_tool @fullscreen_cmd, @window_cmd
  end


  def active?
    @fullscreen_cmd == current_fullscreen_cmd and
      @window_cmd == current_window_cmd
  end

  def can_configure_current_window_manager?
    # TODO: Need to detect if Metacity is running
    true
  end


  def restore_system_default
    `gconftool --unset /apps/metacity/keybinding_commands/command_screenshot`
    assert_exit
    `gconftool --unset /apps/metacity/keybinding_commands/command_window_screenshot`
    assert_exit

    $stderr.puts "Fullscreen tool is now '#{ current_fullscreen_cmd }' and window tool is '#{ current_window_cmd }'"
  end


  private

  def assert_exit
    if not $?.success?
      raise PrintScreenConfigureFailed
    end
  end



  def set_tool(fullscreen, window)
    `gconftool --type string --set /apps/metacity/keybinding_commands/command_screenshot "#{ fullscreen }"`
    assert_exit
    `gconftool --type string --set /apps/metacity/keybinding_commands/command_window_screenshot "#{ window }"`
    assert_exit

    $stderr.puts "Fullscreen tool is now '#{ current_fullscreen_cmd }' and window tool is '#{ current_window_cmd }'"
  end

  def current_fullscreen_cmd
    ret = `gconftool --get /apps/metacity/keybinding_commands/command_screenshot`.strip
    assert_exit
    ret
  end

  def current_window_cmd
    ret = `gconftool --get /apps/metacity/keybinding_commands/command_window_screenshot`.strip
    assert_exit
    ret
  end


end
