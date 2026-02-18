extends Control

var entries := [
	"Start_Game",
	"Tutorial",
	"Settings",
	"Credits"
]

var scenes := {
	"Start_Game": "res://SCENE_AND_SCRIPT/TMP/Test_Split_Screen.tscn",
	"Tutorial": "res://SCENE_AND_SCRIPT/Tutorial.tscn",
	"Settings": "res://SCENE_AND_SCRIPT/Settings.tscn",
	"Credits": "res://SCENE_AND_SCRIPT/Credits.tscn"
}

var start_game_scene := preload("res://SCENE_AND_SCRIPT/TMP/Test_Split_Screen.tscn")

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
		var selected_entry = entries[current_index]
		if selected_entry in scenes:
			if selected_entry == "Start_Game":
				Music.play_bang()
				get_tree().change_scene_to_file(start_game_scene.resource_path)
			else:
				get_tree().change_scene_to_file(scenes[selected_entry])

	elif event.is_action_pressed("ui_b_button"):
		UISounds.play_cancel()
		get_tree().change_scene_to_file("res://SCENE_AND_SCRIPT/Title.tscn")

func update_menu() -> void:
	for i in range(entries.size()):
		var entry_name = entries[i]
		var on_label  = get_node_or_null(entry_name + "_On")
		var off_label = get_node_or_null(entry_name + "_Off")
		if not on_label or not off_label:
			continue
		
		var selected = (i == current_index)
		on_label.visible  = selected
		off_label.visible = not selected
