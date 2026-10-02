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

var _runner_corners = [
	Globals.Corner.N,
	Globals.Corner.S,
	Globals.Corner.W,
	Globals.Corner.E
]

@onready var _viewports = [
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport,
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport,
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport,
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport
]

func _ready():

	# create the map, which will be shared by all viewports

	var map = _map_scene.instantiate()
	map.map_size = Globals.map_size
	_viewports[0].add_child(map)

	for i in 4:

		# create a runner

		var runner = _runner_scenes[i].instantiate()
		runner.input_device = i
		runner.bonus_found.connect(_on_bonus_found)
		_runners.append(runner)

		# all viewports share the same 2D world

		if i > 0:
			_viewports[i].world_2d = _viewports[0].world_2d

		# add the runner and a camera to the viewport (runners are shared among
		# viewports, cameras are not)

		var camera = Camera2D.new()
		camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
		_viewports[i].add_child(runner)
		_viewports[i].add_child(camera)
		runner.set_environment(map, _runner_corners[i], camera)

		# create bots for all runners except the first

		if i > 0:
			var bot = Bot.new(runner, map, _runner_corners[i])
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
