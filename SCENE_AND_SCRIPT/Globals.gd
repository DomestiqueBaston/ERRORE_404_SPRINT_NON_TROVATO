extends Node

var use_diagonals_for_movement: bool = true

const _settings_path = "user://settings.cfg"

func _ready():
	load_settings()

func _input(event):
	if event.is_action_pressed("ui_fullscreen"):
		var mode := DisplayServer.window_get_mode()

		if mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func save_settings():
	var config = ConfigFile.new()
	config.set_value("settings", "use_diagonals", use_diagonals_for_movement)
	config.save(_settings_path)

func load_settings():
	var config = ConfigFile.new()
	if config.load(_settings_path) == OK:
		use_diagonals_for_movement = config.get_value("settings", "use_diagonals", true)
