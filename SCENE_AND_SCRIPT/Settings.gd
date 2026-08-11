extends Node2D

@onready var _parameters = $Parameters

func _ready():
	_parameters.update()

func _input(event):
	if event.is_action_pressed("ui_b_button"):
		Sounds.play_cancel()
		_reset_settings()
		get_viewport().set_input_as_handled()
		_switch_to_menu()

	elif event.is_action_pressed("ui_a_button"):
		Sounds.play_validation()
		_update_settings()
		get_viewport().set_input_as_handled()
		_switch_to_menu()

func _switch_to_menu():
	Sounds.play_bang()
	var menu_scene = load("res://SCENE_AND_SCRIPT/Menu.tscn")
	get_tree().call_deferred("change_scene_to_packed", menu_scene)

#
# Updates global settings and saves them when the player confirms. Note that
# audio settings are updated immediately, when the player moves the sliders, so
# audio settings do not need to be updated first: they need to be RESET when the
# player cancels.
#
func _update_settings():
	Globals.use_diagonals_for_movement = _parameters.get_use_diagonals()
	Globals.map_size = _parameters.get_map_size()
	Globals.difficulty = _parameters.get_difficulty()
	Globals.save_settings()

#
# Reverts audio settings to their initial state when the player cancels.
#
func _reset_settings():
	_parameters.reset()
