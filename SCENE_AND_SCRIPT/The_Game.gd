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
var _bots: Array[Bot]

var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")
var _woman_a_scene = preload("res://SCENE_AND_SCRIPT/Woman_A.tscn")
var _woman_b_scene = preload("res://SCENE_AND_SCRIPT/Woman_B.tscn")
var _man_a_scene = preload("res://SCENE_AND_SCRIPT/Man_A.tscn")
var _man_b_scene = preload("res://SCENE_AND_SCRIPT/Man_B.tscn")

func _ready():
	var map = _map_scene.instantiate()
	map.map_size = Globals.map_size

	var runner1 = _woman_a_scene.instantiate()
	var runner2 = _woman_b_scene.instantiate()
	var runner3 = _man_a_scene.instantiate()
	var runner4 = _man_b_scene.instantiate()

	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(map)

	_add_runner_to_viewport(
		$Runners/Top_Runners/Left_Runner/Runner_SubViewport,
		map, Globals.Corner.N, runner1, false)
	_add_runner_to_viewport(
		$Runners/Top_Runners/Right_Runner/Runner_SubViewport,
		map, Globals.Corner.S, runner2, true)
	_add_runner_to_viewport(
		$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport,
		map, Globals.Corner.W, runner3, true)
	_add_runner_to_viewport(
		$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport,
		map, Globals.Corner.E, runner4, true)

	var world = $Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world

	runner1.input_device = 0
	runner2.input_device = 1
	runner3.input_device = 2
	runner4.input_device = 3

func _add_runner_to_viewport(
	viewport: SubViewport, map: Map, start_corner: Globals.Corner,
	runner: Runner, make_bot: bool = false):
	var camera = Camera2D.new()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	viewport.add_child(camera)
	viewport.add_child(runner)
	runner.set_environment(map, start_corner, camera)

	if make_bot:
		var bot = Bot.new()
		bot.map = map
		bot.runner = runner
		bot.start_corner = start_corner
		add_child(bot)
		_bots.append(bot)

func _unhandled_input(event: InputEvent) -> void:
	# Détection de la première action du joueur
	for action in START_ACTIONS:
		if event.is_action_pressed(action):
			_can_restart = true
			if _once:
				Sounds.stop_intro()
				Sounds.play_music()
				for bot in _bots:
					bot.start()
				_once = false
			break

	# Redémarrage de la scène (pour test)
	if _can_restart and event.is_action_pressed("ui_tab_button"):
		Sounds.stop_all()
		Sounds.play_bang()
		Sounds.play_intro()
		get_tree().reload_current_scene()
