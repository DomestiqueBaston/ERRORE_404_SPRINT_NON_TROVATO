@tool
class_name Cube extends CellAttachment

@export var bonus_type: Bonus.Type:
	get():
		return _bonus.type
	set(t):
		_bonus.type = t
		if is_node_ready():
			_update_color()

var _bonus: Bonus = Bonus.new()

@onready var _anim_alive: AnimationPlayer = $Animation_Cube
@onready var _anim_on_off: AnimationPlayer = $Animation_Cube_On_Off
@onready var _collider: Area2D = $Collider_Cube

func _ready():
	_update_color()

func get_bonus() -> Bonus:
	return _bonus

func _update_color():
	$Cube.set_instance_shader_parameter(&"sprite_color", _get_sprite_color())

func appear():
	_anim_alive.play(&"Alive")
	_anim_on_off.play(&"Appearing")
	await _anim_on_off.animation_finished

func disappear():
	_anim_on_off.play(&"Disappearing")
	await _anim_on_off.animation_finished
	_anim_alive.play(&"RESET")

##
## Returns true if the given collider overlaps with the cube's collider. This is
## computed by the physics server at each tick, before calling nodes'
## _physics_process() functions.
##
func check_for_overlap(collider: Area2D) -> bool:
	return collider.overlaps_area(_collider)

func _get_sprite_color() -> Color:
	match _bonus.type:
		Bonus.Type.INVINCIBLE, Bonus.Type.INVERT:
			return Color(1.0, 0.92, 0.92)
		Bonus.Type.DASH, Bonus.Type.ANTI_DASH:
			return Color(0.917, 1.0, 0.9)
		Bonus.Type.PIERCE_WALLS, Bonus.Type.PHASE:
			return Color(0.91, 0.928, 1.0)
		Bonus.Type.VIRUS, Bonus.Type.ANTI_VIRUS:
			return Color(0.943, 0.91, 1.0)
		Bonus.Type.AUTO_DODGE, Bonus.Type.NO_TURN:
			return Color(0.976, 1.0, 0.88)
		Bonus.Type.DEBUG, Bonus.Type.SLOW:
			return Color(0.92, 0.92, 0.92)
		_:
			return Color.WHITE
