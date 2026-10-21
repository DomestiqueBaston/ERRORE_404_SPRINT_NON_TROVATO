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

var _viewport_runners: Array[int]
var _choosing_players: bool = false
var _once := true
var _can_restart := false
var _map: Map
var _runners: Array[Runner]
var _cameras: Array[Camera2D]
var _bots: Array[Bot]

var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")

var _runner_corners: Array[Globals.Corner] = [
	Globals.Corner.N,
	Globals.Corner.S,
	Globals.Corner.W,
	Globals.Corner.E
]

@onready var _viewports: Array[SubViewport] = [
	$Runners/Top_Runners/Left_Runner/Runner_SubViewport,
	$Runners/Top_Runners/Right_Runner/Runner_SubViewport,
	$Runners/Bottom_Runners/Left_Runner/Runner_SubViewport,
	$Runners/Bottom_Runners/Right_Runner/Runner_SubViewport
]

func _ready():

	# create the map, which will be shared by all viewports

	_map = _map_scene.instantiate()
	_map.map_size = Globals.map_size
	_viewports[0].add_child(_map)

	# create runners and their cameras

	_viewport_runners.resize(4)

	for i in 4:

		# create a runner

		var scene = "res://SCENE_AND_SCRIPT/%s.tscn" % Globals.runner_scene_names[i]
		var runner = load(scene).instantiate()
		runner.bonus_found.connect(_on_bonus_found.bind(runner))
		runner.start_bug.connect(_on_bug_enabled.bind(runner, true))
		runner.stop_bug.connect(_on_bug_enabled.bind(runner, false))
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
		runner.set_environment(_map, _runner_corners[i], camera)
		_cameras.append(camera)

		# by default, runner i is assigned to viewport i

		_viewport_runners[i] = i

	# choose which runner the player will control

	_choosing_players = true
	$Frames/Player_Selection/Portraits_Top_Left.show()
	$Frames/Player_Selection/Portraits_Top_Left.start()
	$Frames/Player_Selection.show()

func _start_race():
	_choosing_players = false

	# hide the player selection UI

	$Frames/Player_Selection.hide()
	$Frames/Player_Selection/Portraits_Top_Left.stop()

	# assign input devices to runners: input device 0 for viewport 0, etc., and
	# start up the map and runners (timers, input handling, etc.)

	for i in 4:
		var runner_index = _viewport_runners[i]
		var runner = _runners[runner_index]
		runner.input_device = i
		runner.start()

	_map.start()

	# create bots for runners in all viewports except the first

	var behavior_traits = Bot.BehaviorTrait.values().duplicate()
	var bonus_traits = Bot.BonusTrait.values().duplicate()
	var sensory_traits = Bot.SensoryTrait.values().duplicate()

	for i in range(1, 4):
		var runner_index = _viewport_runners[i]
		var runner = _runners[runner_index]
		var bot = Bot.new(runner, _map, _runner_corners[i])
		var st = sensory_traits.pop_at(randi() % sensory_traits.size())
		var bt = behavior_traits.pop_at(randi() % behavior_traits.size())
		var bmt = bonus_traits.pop_at(randi() % bonus_traits.size())
		if bt != Bot.BehaviorTrait.NORMAL:
			bot.behavior = bt
			print("%s is %s" % [runner.name, Bot.BehaviorTrait.keys()[bt].capitalize()])
		if bmt != Bot.BonusTrait.NORMAL:
			bot.bonus_behavior = bmt
			print("%s is %s" % [runner.name, Bot.BonusTrait.keys()[bmt].capitalize()])
		if st != Bot.SensoryTrait.NORMAL:
			bot.apply_sensory_trait(st)
			print("%s is %s" % [runner.name, Bot.SensoryTrait.keys()[st].capitalize()])
		add_child(bot)
		_bots.append(bot)

	# useless alarms

	var alarm_timer = Timer.new()
	alarm_timer.timeout.connect(_on_alarm_timeout)
	add_child(alarm_timer)
	alarm_timer.start(10)

func _scroll_portrait(incr: int):
	var portrait = $Frames/Player_Selection/Portraits_Top_Left
	if not await portrait.scroll(incr):
		return

	var selected_runner = portrait.get_character_index()
	Sounds.play_disappearing()

	# remove all characters from viewports

	for i in 4:
		var runner_index = _viewport_runners[i]
		var runner = _runners[runner_index]
		if i < 4:
			runner.blink()
		else:
			await runner.blink()

	for i in 4:
		var runner_index = _viewport_runners[i]
		var runner = _runners[runner_index]
		_viewports[i].remove_child(runner)

	# put the newly selected character in the first viewport

	var player: Runner = _runners[selected_runner]
	_viewports[0].add_child(player)
	_viewport_runners[0] = selected_runner
	player.set_environment(_map, _runner_corners[0], _cameras[0])

	# assign other characters to other viewports at random

	var runner_indices: Array[int]
	for i in range(1, 4):
		runner_indices.push_back((selected_runner + i) % 4)

	for i in range(1, 4):
		var runner_index = runner_indices.pop_at(randi() % runner_indices.size())
		var runner = _runners[runner_index]
		_viewports[i].add_child(runner)
		_viewport_runners[i] = runner_index
		runner.set_environment(_map, _runner_corners[i], _cameras[i])
		runner.blink()

func _input(event: InputEvent):
	if _choosing_players:
		if event.is_action_pressed(&"ui_left_button"):
			_scroll_portrait(-1)
		elif event.is_action_pressed(&"ui_right_button"):
			_scroll_portrait(1)
		elif event.is_action_pressed(&"ui_a_button"):
			_start_race()
		# TODO: handle quit button action
		return

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

func _on_bonus_found(bonus: Bonus, runner: Runner):
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
			while not candidates.is_empty():
				var other_runner = candidates.pick_random()
				if other_runner != runner and other_runner.is_alive():
					other_runner.apply_bonus(bonus)
					break

func _on_bug_enabled(bug: Globals.Bug, runner: Runner, enable: bool):
	var bugs_node: Node

	for i in _runners.size():
		if _runners[i] == runner:
			bugs_node = $Frames.get_node("Bugs_0%d" % (i+1))
			break

	if bugs_node == null:
		return

	var color_rect: ColorRect

	match bug:
		Globals.Bug.BLUR:
			color_rect = bugs_node.get_node(^"Blur_Glitches")
		Globals.Bug.SHAKE:
			color_rect = bugs_node.get_node(^"Shake")
		Globals.Bug.INVERT_COLORS:
			color_rect = bugs_node.get_node(^"Invert_Colors")
		Globals.Bug.PIXELATE:
			color_rect = bugs_node.get_node(^"Pixelate")
		Globals.Bug.JPEG:
			color_rect = bugs_node.get_node(^"Jpeg")

	if color_rect:
		color_rect.visible = enable

func _on_alarm_timeout():
	match randi() % 20:
		0:
			Sounds.play_useless_alarm1()
		1:
			Sounds.play_useless_alarm2()
