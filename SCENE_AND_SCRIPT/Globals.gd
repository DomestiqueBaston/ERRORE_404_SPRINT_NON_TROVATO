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

enum Bug {
	NONE,
	CAMERA_OFFSET,
	BLUR,
	SHAKE,
	INVERT_COLORS,
	PIXELATE,
	JPEG
}

var NORTHWEST: Vector2
var NORTHEAST: Vector2
var SOUTHWEST: Vector2
var SOUTHEAST: Vector2

const MASTER_BUS: int = 0
const MUSIC_BUS: int = 5

const RUNNER_LAYER: int = 0x01
const GROUND_LAYER: int = 0x02
const WALL_LAYER: int = 0x04
const DOOR_LAYER: int = 0x08
const ONE_WAY_LAYER: int = 0x10
const CUBE_LAYER: int = 0x20

const runner_scene_names: Array[String] = [
	"Woman_A",
	"Man_A",
	"Woman_B",
	"Man_B"
]

var use_diagonals_for_movement: bool = true
var map_size: int = 7
var difficulty: int = 3
var max_difficulty: int = 5

const _settings_path = "user://settings.cfg"

func _ready():
	const _rotation: float = deg_to_rad(18.4)
	NORTHWEST = Vector2(-1, -1).rotated(-_rotation).normalized()
	NORTHEAST = Vector2(1, -1).rotated(_rotation).normalized()
	SOUTHWEST = Vector2(-1, 1).rotated(_rotation).normalized()
	SOUTHEAST = Vector2(1, 1).rotated(-_rotation).normalized()

	load_settings()

	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

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
	config.set_value("settings", "master_db", AudioServer.get_bus_volume_db(MASTER_BUS))
	config.set_value("settings", "music_db", AudioServer.get_bus_volume_db(MUSIC_BUS))
	config.save(_settings_path)
	MapBuilder.update_map_size()

func load_settings():
	var config = ConfigFile.new()
	if config.load(_settings_path) == OK:
		use_diagonals_for_movement = config.get_value("settings", "use_diagonals", true)
		map_size = config.get_value("settings", "map_size", 7)
		difficulty = config.get_value("settings", "difficulty", 3)
		AudioServer.set_bus_volume_db(MASTER_BUS, config.get_value("settings", "master_db", 0.0))
		AudioServer.set_bus_volume_db(MUSIC_BUS, config.get_value("settings", "music_db", -7.5))
	MapBuilder.update_map_size()

func axis_to_dir(axis: Globals.Axis) -> Vector2:
	match axis:
		Axis.NW:
			return NORTHWEST
		Axis.NE:
			return NORTHEAST
		Axis.SW:
			return SOUTHWEST
		Axis.SE:
			return SOUTHEAST
	return Vector2.ZERO

func dir_to_axis(dir: Vector2) -> Axis:
	if dir.x > 0:
		if dir.y > 0:
			return Axis.SE
		else:
			return Axis.NE
	else:
		if dir.y > 0:
			return Axis.SW
		else:
			return Axis.NW

##
## Returns true if the two given directions are the same. It is assumed that
## they are each one of the four possible directions for runners.
##
func compare_directions(dir1: Vector2, dir2: Vector2) -> bool:
	return dir_to_axis(dir1) == dir_to_axis(dir2)
