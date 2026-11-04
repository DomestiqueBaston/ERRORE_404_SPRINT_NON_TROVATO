extends Control

@onready var _anim: AnimationPlayer = $Animation_Text

func start():
	_anim.play(&"Writing")
	await _anim.animation_finished
	_anim.play(&"Final_Blink")
