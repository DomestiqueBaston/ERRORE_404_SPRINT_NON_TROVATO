extends Node2D


@onready var menu_scene: PackedScene = load("res://SCENE_AND_SCRIPT/Menu.tscn")


func _input(event):
	if event is InputEventJoypadButton and event.pressed:
		if event.is_action_pressed("ui_b_button"):
			UISounds.play_cancel()
			Music.play_bang()
			get_tree().call_deferred("change_scene_to_packed", menu_scene)
