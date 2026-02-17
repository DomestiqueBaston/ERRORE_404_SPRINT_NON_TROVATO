extends Control

var entries := [
	"Start_Game",
	"Tutorial",
	"Settings",
    "Credits"
]

var current_index: int = 0

func _ready():
	for entry_name in entries:
		var on_label = get_node_or_null(entry_name + "_On")
		var off_label = get_node_or_null(entry_name + "_Off")
		if on_label:
			on_label.visible = false
		if off_label:
			off_label.visible = true

	current_index = 0
	update_menu()

func _unhandled_input(event):
	if event.is_action_pressed("ui_down_button"):
		current_index = (current_index + 1) % entries.size()
		update_menu()

	elif event.is_action_pressed("ui_up_button"):
		current_index = (current_index - 1 + entries.size()) % entries.size()
		update_menu()

	elif event.is_action_pressed("ui_a_button"):
		activate_current()

func update_menu():
	for i in entries.size():
		var entry_name = entries[i]
		var on_label = get_node_or_null(entry_name + "_On")
		var off_label = get_node_or_null(entry_name + "_Off")
		if not on_label or not off_label:
			continue

		var selected := (i == current_index)
		on_label.visible = selected
		off_label.visible = !selected

func activate_current():
	match entries[current_index]:
		"Start_Game":
			print("Start game")
		"Tutorial":
			print("Tutorial")
		"Settings":
			print("Settings")
		"Credits":
			print("Credits")
