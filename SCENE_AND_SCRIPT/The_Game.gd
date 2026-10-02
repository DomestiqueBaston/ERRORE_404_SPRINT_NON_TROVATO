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
var _runners: Array[Runner]
var _bots: Array[Bot]

var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")
var _runner_scenes = [
	preload("res://SCENE_AND_SCRIPT/Woman_A.tscn"),
	preload("res://SCENE_AND_SCRIPT/Woman_B.tscn"),
	preload("res://SCENE_AND_SCRIPT/Man_A.tscn"),
	preload("res://SCENE_AND_SCRIPT/Man_B.tscn")
]

func _ready():
	var map = _map_scene.instantiate()
	map.map_size = Globals.map_size

	for i in _runner_scenes.size():
		var runner = _runner_scenes[i].instantiate()
		runner.input_device = i
		runner.bonus_found.connect(_on_bonus_found)
		_runners.append(runner)

	$Runners/Top_Runners/Left_Runner/Runner_SubViewport.add_child(map)

	_add_runner_to_viewport(
		$Runners/Top_Runners/Left_Runner/Runner_SubViewport,
		map, Globals.Corner.N, _runners[0], false)
	_add_runner_to_viewport(
		$Runners/Top_Runners/Right_Runner/Runner_SubViewport,
		map, Globals.Corner.S, _runners[1], true)
	_add_runner_to_viewport(
		$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport,
		map, Globals.Corner.W, _runners[2], true)
	_add_runner_to_viewport(
		$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport,
		map, Globals.Corner.E, _runners[3], true)

	var world = $Runners/Top_Runners/Left_Runner/Runner_SubViewport.world_2d
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport.world_2d = world
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport.world_2d = world

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

func _on_bonus_found(runner: Runner, bonus: Bonus):
	match bonus.type:
		Bonus.Type.VANISH_WALLS:
			for r in _runners:
				if r != runner:
					r.vanish_walls()
		Bonus.Type.EXTEND_WALLS:
			for r in _runners:
				if r != runner:
					r.extend_walls()
		_:
			var candidates = _runners.duplicate()
			candidates.erase(runner)
			var other_runner = candidates.pick_random()
			other_runner.apply_bonus(bonus)
