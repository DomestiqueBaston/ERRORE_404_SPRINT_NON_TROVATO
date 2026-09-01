class_name Artefact extends Node2D

func _ready():
	# Z index is relative to the parent cell's
	z_index = Globals.PYLON_Z_OFFSET

func disappear():
	var anim: AnimationPlayer = $Animation_Artefact_Off
	anim.play("Disappearing")
	await anim.animation_finished
