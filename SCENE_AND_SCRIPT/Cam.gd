extends Camera2D

@onready var _init_pos = position.round()

# Sans ça, on a des artefacts de lignes verticales sur les Cells
# Peut-être ailleurs mais je ne vois rien...

func update_aim_point(pos: Vector2):
	global_position = _init_pos + pos.round()
