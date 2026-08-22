extends Node2D

@onready var shadow_orientation: Node2D = $Shadow_Orientation
@onready var direction_orientation: Node2D = $Direction_Orientation

var _direction: Globals.Axis

func set_direction(dir: Globals.Axis):
	_direction = dir
	match dir:
		Globals.Axis.NW:
			shadow_orientation.position = Vector2(0.0, 119.0)
			shadow_orientation.scale = Vector2(-1.0, -1.0)
			direction_orientation.position = Vector2(15.0, 60.0)
			direction_orientation.scale = Vector2(-1.0, -1.0)
		Globals.Axis.NE:
			shadow_orientation.position = Vector2(0.0, 119.0)
			shadow_orientation.scale = Vector2(1.0, -1.0)
			direction_orientation.position = Vector2(-15.0, 60.0)
			direction_orientation.scale = Vector2(1.0, -1.0)
		Globals.Axis.SW:
			shadow_orientation.position = Vector2(0.0, 0.0)
			shadow_orientation.scale = Vector2(-1.0, 1.0)
			direction_orientation.position = Vector2(15.0, -75.0)
			direction_orientation.scale = Vector2(-1.0, 1.0)
		Globals.Axis.SE:
			shadow_orientation.position = Vector2(0.0, 0.0)
			shadow_orientation.scale = Vector2(1.0, 1.0)
			direction_orientation.position = Vector2(-15.0, -75.0)
			direction_orientation.scale = Vector2(1.0, 1.0)

func get_direction() -> Globals.Axis:
	return _direction
