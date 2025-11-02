extends Node2D

func _ready():
	var world = $BG_SubViewport.find_world_2d()
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world
