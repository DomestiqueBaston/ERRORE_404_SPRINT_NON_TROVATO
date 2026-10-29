extends Node2D

@onready var _menu_scene: PackedScene = load("res://SCENE_AND_SCRIPT/Menu.tscn")
@onready var _info_overlay = $Graphics/Info_Overlay

var _is_info_overlay_ready: bool = false
var _is_quit_button_visible: bool = false

func _ready():
	$Graphics/Info_Overlay.hide()
	$Graphics/BackBufferCopy_Reflection.show()
	$Quit_Button.button_toggled.connect(_on_quit_button_toggled)

func _input(event):
	if event.is_action_pressed("ui_a_button"):
		Sounds.play_validation()
		Sounds.play_bang()
		get_viewport().set_input_as_handled()
		get_tree().call_deferred("change_scene_to_packed", _menu_scene)

#
# Called by the AnimationPlayer almost immediately to turn on sound and visual
# effects.
#
func play_bang_title():
	Sounds.play_bang()
	$Graphics/BackBufferCopy_Reflection.show()
	$Graphics/Glitches.show()
	$Graphics/Glitches/Sound_Animation.play("Glitchy_Sound")
	Sounds.play_intro()

#
# Called by the AnimationPlayer after a while to display Info_Overlay.
#
func show_info_overlay():
	_is_info_overlay_ready = true
	if not _is_quit_button_visible:
		_info_overlay.show_overlay()

func _on_quit_button_toggled(toggled: bool):
	_is_quit_button_visible = toggled
	if _is_info_overlay_ready:
		if toggled:
			_info_overlay.hide_overlay()
		else:
			_info_overlay.show_overlay()
