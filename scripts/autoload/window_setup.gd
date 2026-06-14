extends Node

## Borderless window covering the full monitor (still windowed — Alt+Tab works).


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		return

	call_deferred("_apply_fullscreen_window")


func _apply_fullscreen_window() -> void:
	var screen_index := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen_index)
	var screen_pos := DisplayServer.screen_get_position(screen_index)

	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_RESIZE_DISABLED, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(screen_size)
	DisplayServer.window_set_position(screen_pos)
