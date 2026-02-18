extends Node2D


func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if not (event.is_action_pressed("ui_quit_button") or event.is_action_pressed("ui_fullscreen")):
			Music.play_bang()
			get_tree().change_scene_to_file("res://SCENE_AND_SCRIPT/Menu.tscn")
