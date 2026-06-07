extends Node2D


@onready var menu_scene: PackedScene = load("res://SCENE_AND_SCRIPT/Menu.tscn")


func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if event.is_action_pressed("ui_b_button"):
			Sounds.play_cancel()
			Music.play_bang()
			get_viewport().set_input_as_handled()
			get_tree().call_deferred("change_scene_to_packed", menu_scene)
