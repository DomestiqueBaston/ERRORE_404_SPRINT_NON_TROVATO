class_name Bot extends Node

## A Bot autonomously controls the actions of a Runner navigating a Map, with no
## user input. Set the runner and the map variables, at least, and then call
## start(). The bot then takes control of the character and starts running until
## he dies.

## Which runner this bot controls.
var runner: Runner: set = set_runner

## The map the runner is navigating.
var map: Map

## Which corner of the map the runner starts from.
var start_corner: Globals.Corner

## Scale factor applied to the runner's area of vision.
var vision_scale: float = 0.5

## Minimum amount of time between two actions (seconds).
var action_time_limit: float = 0.05

## The bot will not take more than two actions in this amount of time (seconds).
var two_action_time_limit: float = 0.150

var _next_cell: Cell
var _action_times: Array[float]

func _ready():
	set_physics_process(false)
	runner.died.connect(func(): set_physics_process(false))

#
# Call this whenever an action is taken so we can keep track of when actions
# were taken and thus when a new action can be taken.
#
func _add_action_taken():
	while _action_times.size() > 1:
		_action_times.pop_front()
	_action_times.push_back(0)

#
# Returns true if the bot can take a new action now, given the time constraints.
# The constraints are that at least action_time_limit seconds separate any two
# actions, and that no more than two actions can be taken in a span of
# two_action_time_limit seconds.
#
func _can_take_action() -> bool:
	if _action_times.size() > 0:
		if _action_times.back() < action_time_limit:
			return false
		if _action_times.size() > 1 and _action_times[-2] < two_action_time_limit:
			return false
	return true

func _physics_process(delta: float):

	# keep track of how much time has elapsed since previous actions were taken

	for t in _action_times.size():
		_action_times[t] += delta

	if not _can_take_action():
		return

	var next_pos = _get_next_pos(runner.direction)
	var next_cell = map.get_cell_at_pos(next_pos)

	if _next_cell != next_cell:
		if _next_cell:
			var collider = _next_cell.get_node("Column/Collider_Ground")
			if collider:
				collider.hide()
		_next_cell = next_cell
		if _next_cell:
			var collider = _next_cell.get_node("Column/Collider_Ground")
			if collider:
				collider.show()

	if not _is_cell_clear(_next_cell):
		_turn()

func set_runner(r: Runner):
	if runner != r:
		if runner:
			runner.runner_seen.disconnect(_on_runner_seen)
		runner = r
		if runner:
			runner.runner_seen.connect(_on_runner_seen)

##
## Starts running. Be sure to set the runner and the map before calling this.
## The bot takes control of the runner until he dies.
##
func start():
	runner.set_vision_area_scale(vision_scale)

	var xsign: int
	var ysign: int

	match start_corner:
		Globals.Corner.N:
			xsign = -1
			ysign = 1
		Globals.Corner.S:
			xsign = 1
			ysign = -1
		Globals.Corner.W:
			xsign = -1
			ysign = -1
		Globals.Corner.E:
			xsign = 1
			ysign = 1

	var sz: int = map.map_size
	var here = Vector2i(xsign * sz, ysign * sz)
	var uv1 = Vector2i(xsign * (sz-1), ysign * sz)
	var uv2 = Vector2i(xsign * sz, ysign * (sz-1))
	var cell1 = map.get_cell_at(uv1)
	var cell2 = map.get_cell_at(uv2)
	var delta: Vector2i

	if _is_cell_clear(cell1):
		delta = uv1 - here
	elif _is_cell_clear(cell2):
		delta = uv2 - here

	if delta.x > 0:
		_send_direction_event(Globals.SOUTHEAST)
	elif delta.x < 0:
		_send_direction_event(Globals.NORTHWEST)
	elif delta.y > 0:
		_send_direction_event(Globals.NORTHEAST)
	elif delta.y < 0:
		_send_direction_event(Globals.SOUTHWEST)

	set_physics_process(true)

func _on_runner_seen(_area: Area2D):
	if _can_take_action():
		_turn()

func _get_next_pos(dir: Vector2) -> Vector2:
	var pos = runner.global_position
	pos.x += (0.5 if dir.x > 0 else -0.5) * Cell.width
	pos.y += (0.5 if dir.y > 0 else -0.5) * Cell.height
	return pos

func _turn():
	var dir1: Vector2
	var dir2: Vector2

	if runner.direction.x > 0:
		if runner.direction.y > 0:
			# going southeast
			dir1 = Globals.NORTHEAST
			dir2 = Globals.SOUTHWEST
		else:
			# going northeast
			dir1 = Globals.NORTHWEST
			dir2 = Globals.SOUTHEAST
	else:
		if runner.direction.y > 0:
			# going southwest
			dir1 = Globals.SOUTHEAST
			dir2 = Globals.NORTHWEST
		else:
			# going northwest
			dir1 = Globals.SOUTHWEST
			dir2 = Globals.NORTHEAST

	var pos1 = _get_next_pos(dir1)
	var pos2 = _get_next_pos(dir2)
	var cell1 = map.get_cell_at_pos(pos1)
	var cell2 = map.get_cell_at_pos(pos2)
	var ok1 = _is_cell_clear(cell1)
	var ok2 = _is_cell_clear(cell2)

	if ok1 and ok2:
		_send_direction_event(dir1 if randi() & 1 else dir2)
	elif ok1:
		_send_direction_event(dir1)
	elif ok2:
		_send_direction_event(dir2)

func _send_direction_event(dir: Vector2):
	if Globals.use_diagonals_for_movement:
		if dir.x > 0:
			_send_action_event(&"ui_right_button")
		else:
			_send_action_event(&"ui_left_button")
		if dir.y > 0:
			_send_action_event(&"ui_down_button")
		else:
			_send_action_event(&"ui_up_button")
	else:
		if dir.x > 0:
			if dir.y > 0:
				_send_action_event(&"ui_right_button")
			else:
				_send_action_event(&"ui_up_button")
		else:
			if dir.y > 0:
				_send_action_event(&"ui_down_button")
			else:
				_send_action_event(&"ui_left_button")
	_add_action_taken()

func _send_action_event(action: StringName):
	var event = InputEventAction.new()
	if runner.input_device >= 0:
		event.device = runner.input_device
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().create_timer(
		2.0 / Engine.physics_ticks_per_second, true, true).timeout
	event.pressed = false
	Input.parse_input_event(event)

func _is_cell_clear(cell: Cell) -> bool:
	return (cell and cell.get_state() == Cell.State.NORMAL
			and cell.get_wall_count() < 2
			and not cell.get_artefact())
