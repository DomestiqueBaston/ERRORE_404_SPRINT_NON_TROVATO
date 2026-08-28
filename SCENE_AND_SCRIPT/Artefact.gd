class_name Artefact extends Node2D

func disappear():
	var anim: AnimationPlayer = $Animation_Artefact_Off
	anim.play("Disappearing")
	await anim.animation_finished
