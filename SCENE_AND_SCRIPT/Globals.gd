extends Node

enum Axis {
	NW,
	NE,
	SW,
	SE
}

enum Corner {
	N,
	S,
	W,
	E
}

const master_bus: int = 0
const music_bus: int = 4

var use_diagonals_for_movement: bool = true
var map_size: int = 7
var difficulty: int = 3
var max_difficulty: int = 5

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
	config.set_value("settings", "map_size", map_size)
	config.set_value("settings", "difficulty", difficulty)
	config.set_value("settings", "master_db", AudioServer.get_bus_volume_db(master_bus))
	config.set_value("settings", "music_db", AudioServer.get_bus_volume_db(music_bus))
	config.save(_settings_path)

func load_settings():
	var config = ConfigFile.new()
	if config.load(_settings_path) == OK:
		use_diagonals_for_movement = config.get_value("settings", "use_diagonals", true)
		map_size = config.get_value("settings", "map_size", 7)
		difficulty = config.get_value("settings", "difficulty", 3)
		AudioServer.set_bus_volume_db(master_bus, config.get_value("settings", "master_db", 0.0))
		AudioServer.set_bus_volume_db(music_bus, config.get_value("settings", "music_db", -7.5))
