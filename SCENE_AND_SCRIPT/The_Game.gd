extends Node2D

enum PortraitStatus {
	# runner selection UI is not open or was cancelled
	NONE,
	# runner selection UI is open
	OPEN,
	# runner selection has been confirmed
	CONFIRMED
}

class ViewportState:
	var camera: Camera2D = null
	var runner_index: int = -1
	var runner_status: PortraitStatus = PortraitStatus.NONE
	var input_device: int = -1

enum GameStatus {
	RUNNER_SELECTION,
	START_BUTTON,
	RACING
}

var _viewport_states: Array[ViewportState]
var _game_status: GameStatus = GameStatus.RUNNER_SELECTION
var _map: Map
var _runners: Array[Runner]
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

@onready var _portraits: Array[Portraits] = [
	$Frames/Player_Selection/Portraits_Top_Left,
	$Frames/Player_Selection/Portraits_Top_Right,
	$Frames/Player_Selection/Portraits_Bottom_Left,
	$Frames/Player_Selection/Portraits_Bottom_Right
]

@onready var _portrait_root: Control = $Frames/Player_Selection
@onready var _start_button: PrettyButton = $Frames/Start_Button

func _ready():

	# create the map, which will be shared by all viewports

	_map = _map_scene.instantiate()
	_map.map_size = Globals.map_size
	_viewports[0].add_child(_map)

	# create runners and their cameras

	_viewport_states.resize(4)

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

		# by default, runner i is assigned to viewport i

		var state = ViewportState.new()
		state.runner_index = i
		state.runner_status = PortraitStatus.NONE
		state.camera = camera
		_viewport_states[i] = state


	# choose which runner the player will control; initially, runner portraits
	# are displayed only for a single player, in the top left viewport

	_get_portrait(0)
	_portrait_root.show()

func _get_set():
	_portrait_root.hide()
	_game_status = GameStatus.START_BUTTON

	# assign input devices to runners and put them in their starting positions

	for i in 4:
		var runner_index = _viewport_states[i].runner_index
		var runner = _runners[runner_index]
		runner.input_device = i
		runner.get_set()

	# create bots for any runners that require them

	var behavior_traits = Bot.BehaviorTrait.values().duplicate()
	var bonus_traits = Bot.BonusTrait.values().duplicate()
	var sensory_traits = Bot.SensoryTrait.values().duplicate()

	for i in 4:
		var state: ViewportState = _viewport_states[i]
		if state.runner_status == PortraitStatus.CONFIRMED:
			continue
		var runner = _runners[state.runner_index]
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

	# display the start button and wait for somebody to press it

	_start_button.done.connect(_on_start)
	_start_button.start()

func _on_start():
	_start_button.stop()

	# start sequence effects

	$Frames/Black_Frames_And_Numbers/Screen_Numbers/Animation_Numbers.play(&"Flashing")
	await get_tree().create_timer(0.5).timeout
	await Sounds.play_three_two_one()
	Sounds.stop_intro()
	Sounds.play_music()
	Sounds.play_go()

	_game_status = GameStatus.RACING

	# useless alarm sounds

	var alarm_timer = Timer.new()
	alarm_timer.timeout.connect(_on_alarm_timeout)
	add_child(alarm_timer)
	alarm_timer.start(10)

	# the map starts creating obstacles, bonus/malus cubes, etc.

	_map.start()

	# the runners can start running

	for runner in _runners:
		runner.go()

	for bot in _bots:
		bot.start(0.5 * randf())

#
# Fetches the viewport where the runner selection UI has been opened for the
# given input device. If none is found, the runner selection UI is opened in
# the next available viewport. Returns the viewport index in either case.
#
func _get_portrait(input_device: int) -> int:

	# if runner selection has already been opened and not cancelled for this
	# input device, return the corresponding viewport

	for i in 4:
		var state: ViewportState = _viewport_states[i]
		if (state.runner_status != PortraitStatus.NONE
			and state.input_device == input_device):
			return i

	# otherwise, open runner selection in the next available viewport

	for i in 4:
		var state: ViewportState = _viewport_states[i]
		if state.runner_status == PortraitStatus.NONE:
			state.runner_status = PortraitStatus.OPEN
			state.input_device = input_device
			_portraits[i].start(state.runner_index)
			_portraits[i].show()
			return i

	return -1

#
# Closes the runner selection UI in the given viewport when the player
# validates (confirm true) or cancels (confirm false). Returns false if the
# given viewport index is invalid or the viewport does not contain an open
# runner selection UI.
#
func _close_portrait(viewport_index: int, confirm: bool) -> bool:
	if viewport_index < 0 or viewport_index >= 4:
		return false

	var state: ViewportState = _viewport_states[viewport_index]
	if state.runner_status != PortraitStatus.OPEN:
		return false

	if confirm:
		state.runner_status = PortraitStatus.CONFIRMED
		for i in 4:
			_portraits[i].disable_character(state.runner_index)
	else:
		state.runner_status = PortraitStatus.NONE

	_portraits[viewport_index].stop()
	_portraits[viewport_index].hide()
	return true

#
# Scrolls to the previous (-1) or next (1) runner in the runner selection UI
# that has been opened in the given viewport.
#
func _scroll_portrait(viewport_index: int, incr: int):
	if viewport_index < 0 or viewport_index >= 4:
		return
	var state: ViewportState = _viewport_states[viewport_index]
	if state.runner_status != PortraitStatus.OPEN:
		return

	# scroll the runner selection UI and see which has been selected

	var portrait = _portraits[viewport_index]
	if not await portrait.scroll(incr):
		return
	var selected_runner = portrait.get_character_index()
	Sounds.play_disappearing()

	# remove unconfirmed characters from viewports

	var available_runners: Array[int] = [0, 1, 2, 3]
	var last_runner: Runner = null

	for i in 4:
		state = _viewport_states[i]
		if state.runner_status == PortraitStatus.CONFIRMED:
			available_runners.erase(state.runner_index)
		else:
			if last_runner:
				last_runner.blink()
			last_runner = _runners[state.runner_index]

	if last_runner:
		await last_runner.blink()
		last_runner = null

	for i in 4:
		state = _viewport_states[i]
		if state.runner_status != PortraitStatus.CONFIRMED:
			var runner = _runners[state.runner_index]
			_viewports[i].remove_child(runner)

	# put the newly selected character in the appropriate viewport

	state = _viewport_states[viewport_index]
	var player: Runner = _runners[selected_runner]
	_viewports[viewport_index].add_child(player)
	state.runner_index = selected_runner
	available_runners.erase(selected_runner)
	player.set_environment(_map, _runner_corners[viewport_index], state.camera)

	# assign other characters to other viewports at random

	for i in 4:
	
		# ignore the viewport where the player just selected a runner, and
		# viewports where the runner has already been confirmed
	
		if i == viewport_index:
			continue
		state = _viewport_states[i]
		if state.runner_status == PortraitStatus.CONFIRMED:
			continue

		# if a player is selecting a runner in this viewport, keep the same
		# runner if possible, otherwise choose a runner at random

		var runner_index
		if (state.runner_status == PortraitStatus.OPEN
			and state.runner_index in available_runners):
			runner_index = state.runner_index
			available_runners.erase(state.runner_index)
		else:
			runner_index = available_runners.pop_at(randi() % available_runners.size())

		# assign the runner to the viewport, and to the player selection UI if
		# open

		var runner = _runners[runner_index]
		_viewports[i].add_child(runner)
		state.runner_index = runner_index
		runner.set_environment(_map, _runner_corners[i], state.camera)
		runner.blink()
		if state.runner_status == PortraitStatus.OPEN:
			_portraits[i].set_character_index(runner_index)

func _input(event: InputEvent):
	if not event.is_action_type():
		return

	# input handling while runners are being selected

	if _game_status == GameStatus.RUNNER_SELECTION:

		# which input device triggered the event? the runner selection UI is
		# opened in the next available viewport whenever a new device is
		# detected

		var input_device = 0
		const MULTI_DEVICE_TEST = false
		if MULTI_DEVICE_TEST:
			if event is InputEventWithModifiers and event.shift_pressed:
				input_device = 1
		else:
			if event.device != InputEvent.DEVICE_ID_KEYBOARD:
				input_device = event.device

		# scroll runners left

		if event.is_action_pressed(&"ui_left_button"):
			var viewport_index = _get_portrait(input_device)
			_scroll_portrait(viewport_index, -1)

		# scroll runners right

		elif event.is_action_pressed(&"ui_right_button"):
			var viewport_index = _get_portrait(input_device)
			_scroll_portrait(viewport_index, 1)

		# confirm runner selection and maybe start the race

		elif event.is_action_pressed(&"ui_a_button"):
			var viewport_index = _get_portrait(input_device)
			if _close_portrait(viewport_index, true):
				Sounds.play_validation()
				var open_count = 0
				var confirmed_count = 0
				for state in _viewport_states:
					match state.runner_status:
						PortraitStatus.OPEN:
							open_count += 1
						PortraitStatus.CONFIRMED:
							confirmed_count += 1
				if open_count == 0 and confirmed_count > 0:
					_get_set()

		# cancel player selection and maybe go back to the menu scene

		elif event.is_action_pressed(&"ui_b_button"):
			var viewport_index = _get_portrait(input_device)
			if _close_portrait(viewport_index, false):
				Sounds.play_cancel()
				var open_count = 0
				for state in _viewport_states:
					if state.runner_status == PortraitStatus.OPEN:
						open_count += 1
				if open_count == 0:
					get_tree().change_scene_to_file("res://SCENE_AND_SCRIPT/Menu.tscn")

	# input handling for the actual race...

	elif _game_status == GameStatus.RACING:

		# reload the scene (for testing only)

		if _game_status == GameStatus.RACING and event.is_action_pressed(&"ui_tab_button"):
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
