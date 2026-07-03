extends Node2D

const START_ACTIONS := [
	"ui_a_button",
	"ui_b_button",
	"ui_x_button",
	"ui_y_button",
	"ui_left_button",
	"ui_right_button",
	"ui_up_button",
	"ui_down_button",
]

var once := true
var can_restart := false

func _ready():
	var world = $BG_SubViewport.find_world_2d()
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world

func _unhandled_input(event: InputEvent) -> void:
	# Détection de la première action du joueur
	for action in START_ACTIONS:
		if event.is_action_pressed(action):
			can_restart = true

			if once:
				Sounds.stop_intro()
				Sounds.play_music()
				once = false

			break

	# Redémarrage de la scène (pour test)
	if can_restart and event.is_action_pressed("ui_tab_button"):
		Sounds.stop_music()
		Sounds.play_bang()
		Sounds.play_intro()
		get_tree().reload_current_scene()
