extends Camera2D

@onready var _init_pos = position.round()

# Sans ça, on a des artefacts de lignes verticales sur les Cells
# Peut-être ailleurs mais je ne vois rien...

# Positions de caméra en fonction de la direction du coureur.
# Ces valeurs sont pour la taille de caméra finale (480 x 235).
#
# Tourné vers le SE : pos.x = -110 et pos.y = -120
# Tourné vers le SO : pos.x = -385 et pos.y = -120
# Tourné vers le NO : pos.x = -385 et pos.y = -225
# Tourné vers le NE : pos.x = -110 et pos.y = -225

func update_aim_point(pos: Vector2):
	global_position = _init_pos + pos.round()
