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

var _once := true
var _can_restart := false

var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")
var _woman_a_scene = preload("res://SCENE_AND_SCRIPT/Woman_A.tscn")
var _woman_b_scene = preload("res://SCENE_AND_SCRIPT/Woman_B.tscn")
var _man_a_scene = preload("res://SCENE_AND_SCRIPT/Man_A.tscn")
var _man_b_scene = preload("res://SCENE_AND_SCRIPT/Man_B.tscn")

func _ready():
	var sz: int = Globals.map_size
	var map = _map_scene.instantiate()
	map.map_size = sz

	var runner1 = _woman_a_scene.instantiate()
	var cellN = map.get_cell_at(Vector2i(-sz, sz))
	runner1.position = cellN.position + Cell.get_start_cell_offset(Globals.Corner.N)
	runner1.set_map(map, cellN)

	var runner2 = _woman_b_scene.instantiate()
	var cellS = map.get_cell_at(Vector2i(sz, -sz))
	runner2.position = cellS.position + Cell.get_start_cell_offset(Globals.Corner.S)
	runner2.set_map(map, cellS)

	var runner3 = _man_a_scene.instantiate()
	var cellW = map.get_cell_at(Vector2i(-sz, -sz))
	runner3.position = cellW.position + Cell.get_start_cell_offset(Globals.Corner.W)
	runner3.set_map(map, cellW)

	var runner4 = _man_b_scene.instantiate()
	var cellE = map.get_cell_at(Vector2i(sz, sz))
	runner4.position = cellE.position + Cell.get_start_cell_offset(Globals.Corner.E)
	runner4.set_map(map, cellE)

	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(map)
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(runner1)
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(runner2)
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(runner3)
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(runner4)

	runner1.set_process_input(true)
	runner2.set_process_input(false)
	runner3.set_process_input(false)
	runner4.set_process_input(false)

	var world = $Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world

	_add_camera_to_viewport($Runners/Top_Runners/Left_Runner/Runner_SubViewport, runner1)
	_add_camera_to_viewport($Runners/Top_Runners/Right_Runner/Runner_SubViewport, runner2)
	_add_camera_to_viewport($Runners/Bottom_Runners/Left_Runner/Runner_SubViewport, runner3)
	_add_camera_to_viewport($Runners/Bottom_Runners/Right_Runner/Runner_SubViewport, runner4)

func _add_camera_to_viewport(viewport: SubViewport, runner: Node2D):
	var camera = Camera2D.new()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	viewport.add_child(camera)

	var remote_xform = RemoteTransform2D.new()
	remote_xform.remote_path = camera.get_path()
	runner.add_child(remote_xform)

func _unhandled_input(event: InputEvent) -> void:
	# Détection de la première action du joueur
	for action in START_ACTIONS:
		if event.is_action_pressed(action):
			_can_restart = true
			if _once:
				Sounds.stop_intro()
				Sounds.play_music()
				_once = false
			break

	# Redémarrage de la scène (pour test)
	if _can_restart and event.is_action_pressed("ui_tab_button"):
		Sounds.stop_music()
		Sounds.play_bang()
		Sounds.play_intro()
		get_tree().reload_current_scene()
