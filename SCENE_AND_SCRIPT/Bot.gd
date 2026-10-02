class_name Bot extends Node

## A Bot autonomously controls the actions of a Runner navigating a Map, with no
## user input. Set the runner and the map variables, at least, and then call
## start(). The bot then takes control of the character and starts running until
## he dies.

## Which runner this bot controls.
var runner: Runner

## The map the runner is navigating.
var map: Map

## Which corner of the map the runner starts from.
var start_corner: Globals.Corner

## Scale factor applied to the runner's area of vision.
const vision_scale: float = 0.5

## When the bot sees an obstacle, it will take it at least this long to react.
const min_reaction_time: float = 0.1

## When the bot sees an obstacle, it will react within this amount of time.
const max_reaction_time: float = 0.2

## After taking an action, the bot will wait at least this long before taking
## another.
const min_move_interval: float = 0.1

## How long before reaching a hole or a pylon the runner should jump or slide.
const jump_slide_runup_time: float = 0.07

#
# Object used to evaluate the runner's options in _react().
#
class RunnerAction:
	# direction to move in
	var dir: Vector2
	# neighboring cell in that direction, if any
	var cell: Cell
	# priority compared to other options: see _evaluate_move()
	var priority: int

# Encourage the runner to turn if he runs in a straight line for this long.
var _max_straight_time: float

# Seconds left before encouraging the runner to turn.
var _turn_timer: float

@warning_ignore("shadowed_variable")
func _init(runner: Runner, map: Map, start_corner: Globals.Corner):
	self.runner = runner
	self.map = map
	self.start_corner = start_corner

func _ready():
	set_physics_process(false)
	runner.died.connect(func(): set_physics_process(false))

func _physics_process(delta: float):
	_turn_timer -= delta

	var next_pos = _get_next_pos(runner.direction)
	var next_cell = map.get_cell_at_pos(next_pos)
	var obstacle = (
		not _is_cell_clear(next_cell)
		or runner.get_visible_runners()
		or _check_for_walls(next_pos, next_cell))

	if obstacle or _turn_timer <= 0.0:
		set_physics_process(false)
		if obstacle:
			var reaction_time = randf_range(min_reaction_time, max_reaction_time)
			await get_tree().create_timer(reaction_time).timeout
		await _react(obstacle)
		set_physics_process(not (runner.is_dead or runner.is_falling))
		_turn_timer = _max_straight_time

##
## Starts running. Be sure to set the runner and the map before calling this.
## The bot takes control of the runner until he dies.
##
func start():
	runner.set_vision_area_scale(vision_scale)

	_max_straight_time = 1.0 + (2 * map.map_size + 1) / 6.0
	_turn_timer = _max_straight_time

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
	var ok1 = _is_cell_clear(cell1)
	var ok2 = _is_cell_clear(cell2)
	var delta: Vector2i

	if ok1 and ok2:
		delta = (uv1 if randi() & 1 else uv2) - here
	elif ok1:
		delta = uv1 - here
	else:
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

#
# Makes the runner change direction, jump and/or slide in response to the
# obstacles surrounding him. If avoiding_obstacle is false, the runner turns if
# he can, but not if that means potentially killing himself.
#
func _react(avoiding_obstacle: bool):
	var other_runners = runner.get_visible_runners()
	var options: Array[RunnerAction]
	var pos: Vector2
	var cell: Cell
	var priority: int

	# continue straight on?

	if avoiding_obstacle:
		var forward = runner.direction
		pos = _get_next_pos(forward)
		cell = map.get_cell_at_pos(pos)
		priority = _evaluate_move(forward, pos, cell, other_runners)
		_add_option_maybe(options, forward, cell, priority)

	# turn left?

	var left = _get_left_dir()
	pos = _get_next_pos(left)
	cell = map.get_cell_at_pos(pos)
	priority = _evaluate_move(left, pos, cell, other_runners)
	_add_option_maybe(options, left, cell, priority)

	# turn right?

	var right = _get_right_dir()
	pos = _get_next_pos(right)
	cell = map.get_cell_at_pos(pos)
	priority = _evaluate_move(right, pos, cell, other_runners)
	_add_option_maybe(options, right, cell, priority)

	# if there is nowhere to go, turn either left or right, which may later
	# result in a u-turn

	if options.is_empty():
		if avoiding_obstacle:
			_send_direction_event(left if randi() & 1 else right)
		return

	# if there is more than one way to go, pick one at random, jumping or
	# sliding as needed

	var option = options.pick_random()
	var jump_or_slide: StringName

	if option.cell == null or option.cell.get_state() in [
		Cell.State.LOWERED, Cell.State.HIDDEN
	]:
		jump_or_slide = &"jump"
	elif option.cell.get_state() == Cell.State.PYLON:
		jump_or_slide = &"slide"

	if option.dir != runner.direction:
		_send_direction_event(option.dir)

	if jump_or_slide:
		var next_pos = _get_next_pos(option.dir)
		var time = _get_time_to_cell_border(next_pos) - jump_slide_runup_time
		await get_tree().create_timer(maxf(time, min_move_interval)).timeout
		if jump_or_slide == &"jump":
			_send_action_event(&"ui_a_button")
		else:
			_send_action_event(&"ui_b_button")

#
# Adds a new RunnerAction to the options array, if priority > 0 and >= the
# priority of the options already in the array. If priority > the priority of
# the existing options, they are replaced.
#
func _add_option_maybe(
	options: Array[RunnerAction], dir: Vector2, cell: Cell, priority: int):
	if priority == 0:
		return

	if not options.is_empty():
		if options[0].priority > priority:
			return
		if options[0].priority < priority:
			options.clear()

	var option = RunnerAction.new()
	option.dir = dir
	option.cell = cell
	option.priority = priority
	options.push_back(option)

#
# Evaluates a potential move in the given direction from the runner's current
# position. The next_pos parameter is a point in the neighboring cell in that
# direction, if there is one (next_cell).
#
# Possible return values are:
#
# 0: The destination contains an unavoidable obstacle, such as a dropped pylon
# or an artefact, or the runner's path is blocked by a wall.
#
# 1: The destination contains another runner, or an obstacle that may be OK,
# such as a one-way sign or a teleport.
#
# 2: The destination contains a hole that can be jumped over, or a pylon that
# can be slid under, or no obstacles at all.
#
func _evaluate_move(
	dir: Vector2, next_pos: Vector2, next_cell: Cell,
	other_runners: Array[Runner]) -> int:

	if _check_for_walls(next_pos, next_cell):
		return 0

	if next_cell == null:
		return 2 if _can_jump_or_slide_over(next_pos, dir) else 0

	if next_cell.get_artefact():
		return 0

	var is_crowded = false
	for other in other_runners:
		if other.get_current_cell() == next_cell:
			is_crowded = true
			break

	if _is_cell_clear(next_cell):
		return 1 if is_crowded else 2

	match next_cell.get_state():
		Cell.State.LOWERED, Cell.State.HIDDEN:
			return 2 if _can_jump_or_slide_over(next_pos, dir) else 0
		Cell.State.TELEPORT, Cell.State.ONE_WAY:
			return 1
		Cell.State.PYLON:
			match next_cell.get_pylon().get_state():
				Pylon.State.RAISED:
					return 1 if is_crowded else 2
				Pylon.State.LOWERED:
					if _can_jump_or_slide_over(next_pos, dir):
						return 1 if is_crowded else 2

	return 0

#
# Given a location and a direction of movement, returns true if the next cell
# over from that location is safe to jump or slide to.
#
func _can_jump_or_slide_over(pos: Vector2, dir: Vector2) -> bool:
	var next_pos = _get_next_pos(dir, pos)
	var next_cell = map.get_cell_at_pos(next_pos)
	return _is_cell_clear(next_cell)

#
# Given a point outside the current cell, returns how long it will take the
# runner to get from his current position to the border of the current cell.
#
func _get_time_to_cell_border(next_pos: Vector2) -> float:
	if runner.get_current_cell():
		var pt = runner.get_current_cell().get_exit_point(
			runner.global_position, next_pos)
		if pt != null:
			return runner.global_position.distance_to(pt) / runner.get_current_speed()
	return 0

#
# Given a direction of movement and a location (which defaults to the runner's
# current position), returns the location one cell further in that direction.
#
func _get_next_pos(dir: Vector2, pos: Vector2 = runner.global_position) -> Vector2:
	pos.x += (0.5 if dir.x > 0 else -0.5) * Cell.width
	pos.y += (0.5 if dir.y > 0 else -0.5) * Cell.height
	return pos

#
# Returns a vector pointing to the left of the runner's current direction.
#
func _get_left_dir() -> Vector2:
	if runner.direction.x > 0:
		if runner.direction.y > 0:
			return Globals.NORTHEAST
		else:
			return Globals.NORTHWEST
	else:
		if runner.direction.y > 0:
			return Globals.SOUTHEAST
		else:
			return Globals.SOUTHWEST

#
# Returns a vector pointing to the right of the runner's current direction.
#
func _get_right_dir() -> Vector2:
	if runner.direction.x > 0:
		if runner.direction.y > 0:
			return Globals.SOUTHWEST
		else:
			return Globals.SOUTHEAST
	else:
		if runner.direction.y > 0:
			return Globals.NORTHWEST
		else:
			return Globals.NORTHEAST

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

func _send_action_event(action: StringName):
	var event = InputEventAction.new()
	if runner.input_device >= 0:
		event.device = runner.input_device
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)

	await get_tree().create_timer(
		2.0 / Engine.physics_ticks_per_second, true, true).timeout

	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)

#
# Performs a quick check for whether the given cell is clear of obvious
# obstacles, and returns true if none are seen. It does NOT check for other
# runners or for walls. Returns false if cell is null.
#
func _is_cell_clear(cell: Cell) -> bool:
	return (cell
			and cell.get_state() in [Cell.State.NORMAL, Cell.State.CUBE]
			and not cell.get_artefact())

#
# Check for walls blocking the runner's path, that is, walls that intersect a
# line segment connecting his current position to next_pos, which is itself
# located on next_cell (which may be null). Returns true if one or more walls
# are in the runner's path.
#
func _check_for_walls(next_pos: Vector2, next_cell: Cell) -> bool:
	for cell in [runner.get_current_cell(), next_cell]:
		if cell == null:
			continue
		for wall in cell.get_walls():
			if not wall.has_points():
				continue
			if Geometry2D.segment_intersects_segment(
				runner.global_position, next_pos,
				wall.get_start_point(), wall.get_end_point()) != null:
				return true
	return false
