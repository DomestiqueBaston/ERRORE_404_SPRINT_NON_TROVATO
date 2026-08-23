extends Node2D

@onready var _dir_anim: AnimationPlayer = $Direction_Animation
@onready var _float_anim: AnimationPlayer = $Direction_Floating

var _direction: Globals.Axis
var _collider: Area2D

func start(direction: Globals.Axis):
	_direction = direction
	var dirname = Globals.Axis.keys()[direction]
	_collider = get_node("%s/Shadow_Orientation/Direction_Collider" % dirname)
	_float_anim.play("Floating")
	_dir_anim.play("%s_Appearing" % dirname)
	await _dir_anim.animation_finished

func stop():
	var dirname = Globals.Axis.keys()[_direction]
	_dir_anim.play("%s_Disappearing" % dirname)
	await _dir_anim.animation_finished
	_float_anim.stop()

func get_direction() -> Globals.Axis:
	return _direction

func get_collider() -> Area2D:
	return _collider
