extends Node2D


func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if event.is_action_pressed("ui_b_button"):
			Music.play_bang()
			get_tree().change_scene_to_file("res://SCENE_AND_SCRIPT/Menu.tscn")
