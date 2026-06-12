extends Node2D

func _ready():
	var world = $BG_SubViewport.find_world_2d()
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world

# Ce qui vient est vraiment inutile, c'est de la "démo" :
var once = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left_button") or event.is_action_pressed("ui_right_button") or event.is_action_pressed("ui_up_button") or event.is_action_pressed("ui_down_button"):
		if once == true:
			Sounds.stop_intro()
			Sounds.play_bang()
			Sounds.play_music()
			
		once = false
