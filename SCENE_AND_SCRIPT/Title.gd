extends Node2D


var menu_scene := preload("res://SCENE_AND_SCRIPT/Menu.tscn")


func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if not (event.is_action_pressed("ui_quit_button") or event.is_action_pressed("ui_fullscreen")):
			UISounds.play_validation()
			Music.play_bang()
			get_tree().change_scene_to_packed(menu_scene)
