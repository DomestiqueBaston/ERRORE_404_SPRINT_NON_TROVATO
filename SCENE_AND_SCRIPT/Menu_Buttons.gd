extends Control

var entries := [
	"Start_Game",
	"Tutorial",
	"Settings",
	"Credits"
]

@onready var preloaded_scenes: Dictionary = {
	"Start_Game": preload("res://SCENE_AND_SCRIPT/TMP/Test_Split_Screen.tscn"),
	"Tutorial":   preload("res://SCENE_AND_SCRIPT/Tutorial.tscn"),
	"Settings":   preload("res://SCENE_AND_SCRIPT/Settings.tscn"),
	"Credits":    preload("res://SCENE_AND_SCRIPT/Credits.tscn"),
	"Title":      preload("res://SCENE_AND_SCRIPT/Title.tscn")
}

var current_index: int = 0


func _ready() -> void:
	for entry_name in entries:
		var on_label  = get_node_or_null(entry_name + "_On")
		var off_label = get_node_or_null(entry_name + "_Off")
		if on_label:
			on_label.visible = false
		if off_label:
			off_label.visible = true
	
	current_index = 0
	update_menu()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down_button"):
		UISounds.play_menu_navigation()
		current_index = (current_index + 1) % entries.size()
		update_menu()

	elif event.is_action_pressed("ui_up_button"):
		UISounds.play_menu_navigation()
		current_index = (current_index - 1 + entries.size()) % entries.size()
		update_menu()

	elif event.is_action_pressed("ui_a_button"):
		UISounds.play_validation()
		Music.play_bang()
		get_viewport().set_input_as_handled()
		var selected = entries[current_index]
		
		if selected in preloaded_scenes:
			var scene: PackedScene = preloaded_scenes[selected]
			
			if selected == "Start_Game":
				Music.play_bang()
			
			get_tree().change_scene_to_packed(scene)


	elif event.is_action_pressed("ui_b_button"):
		UISounds.play_cancel()
		#Music.play_bang() # Supprimer cette ligne règle le problème du double bang au retour à Title.tscn
		get_viewport().set_input_as_handled()
		get_tree().change_scene_to_packed(preloaded_scenes["Title"])


func update_menu() -> void:
	for i in range(entries.size()):
		var entry_name = entries[i]
		var on_label  = get_node_or_null(entry_name + "_On")
		var off_label = get_node_or_null(entry_name + "_Off")
		if not on_label or not off_label:
			continue
		
		var is_selected = (i == current_index)
		on_label.visible  = is_selected
		off_label.visible = not is_selected
