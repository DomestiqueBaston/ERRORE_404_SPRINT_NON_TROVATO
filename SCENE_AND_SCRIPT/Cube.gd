@tool
class_name Cube extends CellAttachment

enum Type {
	INVINCIBLE,
	DASH,
	THROUGH,
	VIRUS,
	AUTO_DODGE,
	DEBUG,
	WALL_BREAKER,
	INVERT,
	SLOW,
	WALL_EXTENDER,
	ANTI_DASH,
	PHASE,
	ANTI_VIRUS,
	NO_TURN
}

@export var type: Type:
	set(t):
		type = t
		if is_node_ready():
			_update_color()

@onready var _anim_alive: AnimationPlayer = $Animation_Cube
@onready var _anim_on_off: AnimationPlayer = $Animation_Cube_On_Off
@onready var _collider: Area2D = $Collider_Cube

func _ready():
	_update_color()

func _update_color():
	$Cube.set_instance_shader_parameter(
		&"sprite_color", Cube.get_sprite_color(type))

func appear():
	_anim_alive.play(&"Alive")
	_anim_on_off.play(&"Appearing")
	await _anim_on_off.animation_finished

func disappear():
	_anim_on_off.play(&"Disappearing")
	await _anim_on_off.animation_finished
	_anim_alive.play(&"RESET")

func grab():
	$Cube_Sound/Grab_Cube.play()

func check_for_overlap(collider: Area2D) -> bool:
	return collider.overlaps_area(_collider)

static func pick_random_type() -> Type:
	return (randi() % Type.keys().size()) as Type

static func get_sprite_color(t: Type) -> Color:
	match t:
		Type.INVINCIBLE, Type.INVERT:
			return Color(1.0, 0.92, 0.92)
		Type.DASH, Type.ANTI_DASH:
			return Color(0.917, 1.0, 0.9)
		Type.THROUGH, Type.PHASE:
			return Color(0.91, 0.928, 1.0)
		Type.VIRUS, Type.ANTI_VIRUS:
			return Color(0.943, 0.91, 1.0)
		Type.AUTO_DODGE, Type.NO_TURN:
			return Color(0.976, 1.0, 0.88)
		Type.DEBUG, Type.SLOW:
			return Color(0.92, 0.92, 0.92)
		_:
			return Color(1, 1, 1)
