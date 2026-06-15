extends Camera2D

func _process(_delta):
	# Sans ça, on a des artefacts de lignes verticales sur les Cells
	# Peut-être ailleurs mais je ne vois rien...
	global_position = global_position.round()
