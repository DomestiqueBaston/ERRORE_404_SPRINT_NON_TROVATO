extends Node2D


@onready var menu_scene: PackedScene = load("res://SCENE_AND_SCRIPT/Menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_a_button") and !event.is_action_pressed("ui_quit_button") and !event.is_action_pressed("ui_fullscreen"):
		Sounds.play_validation()
		Sounds.play_bang()
		get_viewport().set_input_as_handled()
		get_tree().call_deferred("change_scene_to_packed", menu_scene)

func play_bang_title():
	Sounds.play_bang()
	$Graphics/BackBufferCopy_Reflection.show()
	$Graphics/Glitches.show()
	$Graphics/Glitches/Sound_Animation.play("Glitchy_Sound")
	Sounds.play_intro()
