class_name Cube extends CellAttachment

## Couleurs pour les bonus (voir "sprite_color" sur le Shader Material du node Cube) :
## Rouge : Color(1.523, 0.865, 0.865)
## Vert : Color(0.748, 1.164, 0.621)
## Bleu : Color(0.783, 0.883, 1.382)
## Violet : Color(1.037, 0.775, 1.523)
## Jaune : Color(1.231, 1.269, 0.698)
## Gris : Color(0.666, 0.666, 0.666)
## Blanc : Color(1.0, 1.0, 1.0) (par défaut dans le shader)

@onready var _anim_alive: AnimationPlayer = $Animation_Cube
@onready var _anim_on_off: AnimationPlayer = $Animation_Cube_On_Off

func appear():
	_anim_alive.play(&"Alive")
	_anim_on_off.play(&"Appearing")
	await _anim_on_off.animation_finished

func disappear():
	_anim_on_off.play(&"Disappearing")
	await _anim_on_off.animation_finished
	_anim_alive.play(&"RESET")

func check_for_overlap(collider: Area2D) -> bool:
	return collider.overlaps_area($Collider_Cube)
