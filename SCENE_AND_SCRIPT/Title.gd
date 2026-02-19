extends Node2D


@onready var menu_scene: PackedScene = load("res://SCENE_AND_SCRIPT/Menu.tscn")

func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if not (event.is_action_pressed("ui_quit_button") or event.is_action_pressed("ui_fullscreen")):
			UISounds.play_validation()
			Music.play_bang()
			get_tree().call_deferred("change_scene_to_packed", menu_scene)

func play_bang_title():
	Music.play_bang()
	$Graphics/Glitches.show()
	$Graphics/Glitches/Sound_Animation.play("Glitchy_Sound")
	Music.play_intro()
