class_name Artefact extends Node2D

func _ready():
	z_as_relative = false
	z_index = roundi(global_position.y)
	set_notify_transform(true)

func _notification(what: int):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		z_index = roundi(global_position.y)

func disappear():
	var anim: AnimationPlayer = $Animation_Artefact_Off
	anim.play("Disappearing")
	await anim.animation_finished
