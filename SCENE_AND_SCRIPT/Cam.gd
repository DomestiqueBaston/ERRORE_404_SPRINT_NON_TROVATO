extends Camera2D

# Sans ça, on a des artefacts de lignes verticales sur les Cells
# Peut-être ailleurs mais je ne vois rien...

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		var p = global_position.round()
		if global_position != p:
			global_position = p
