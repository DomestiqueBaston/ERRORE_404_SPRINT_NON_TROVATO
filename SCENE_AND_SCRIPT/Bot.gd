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

##
## Traits affecting the bot's behavior.
##
enum BehaviorTrait {
	NORMAL,
	EXTREMIST,
	STUPID,
	DISTRACTED,
	DYSLEXIC,
	EPILEPTIC
}

##
## Traits affecting how well the bot sees and how quickly it reacts.
##
enum SensoryTrait {
	NORMAL,
	VISIONARY,
	MYOPIC,
	REACTIVE,
	SLOW,
	CLUMSY,
	DEXTEROUS
}

var behavior: BehaviorTrait = BehaviorTrait.NORMAL

## Scale factor applied to the runner's area of vision.
var vision_scale: float = 0.5

## When the bot sees an obstacle, it will take it at least this long to react.
var min_reaction_time: float = 0.1

## When the bot sees an obstacle, it will react within this amount of time.
var max_reaction_time: float = 0.2

## After taking an action, the bot will wait at least this long before taking
## another.
var min_move_interval: float = 0.1

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

# Seconds left before the runner is allowed to move again.
var _move_timer: float

# Seconds left before encouraging the runner to turn.
var _turn_timer: float

# Cell containing the exit door.
var _door_cell: Cell

@warning_ignore("shadowed_variable")
func _init(runner: Runner, map: Map, start_corner: Globals.Corner):
	self.runner = runner
	self.map = map
	self.start_corner = start_corner

func _ready():
	set_physics_process(false)
	runner.died.connect(func(): set_physics_process(false))
	runner.escaped.connect(func(): set_physics_process(false))
	map.door_opened.connect(
		func():
			if behavior != BehaviorTrait.EXTREMIST:
				_door_cell = map.get_center_cell())

func _physics_process(delta: float):
	_move_timer -= delta
	_turn_timer -= delta

	# don't try to change direction while navigating the doorway, or jumping or
	# sliding

	if ((_door_cell and _door_cell == runner.get_current_cell())
		or runner.is_jumping or runner.is_sliding):
		return

	var next_pos = _get_next_pos(runner.direction)
	var next_cell = map.get_cell_at_pos(next_pos)
	var other_runners = runner.get_visible_runners()
	var obstacle = (
		not _is_cell_clear(next_cell)
		or other_runners
		or _check_for_walls(next_pos, next_cell))

	# special case for distracted bots: sometimes they don't see the obstacle

	if obstacle and behavior == BehaviorTrait.DISTRACTED and randi() % 50 == 0:
		obstacle = false

	# no obstacle: look for cubes that the bot is interested in

	var cube_option: RunnerAction
	if not obstacle:
		cube_option = _look_for_neighboring_cube(next_cell, other_runners)

	# special case for epileptic bots: half the time they jump or slide for no
	# reason, rather than turning left or right for no reason

	if (not (obstacle or cube_option) and behavior == BehaviorTrait.EPILEPTIC
		and _turn_timer <= 0):
		var r = randi() % 4
		if r < 2:
			set_physics_process(false)
			_send_action_event(&"ui_a_button" if r == 0 else &"ui_b_button")
			if runner.is_alive():
				set_physics_process(true)
				_reset_turn_timer()
			return

	# if something has gotten our attention, turn off physics processing while
	# we handle it, then turn it back on if the runner is still alive

	if obstacle or cube_option or _door_cell or _turn_timer <= 0.0:
		set_physics_process(false)
		if obstacle or cube_option:
			var reaction_time = randf_range(min_reaction_time, max_reaction_time)
			if not runner.get_current_bug() != Globals.Bug.NONE:
				reaction_time += 0.05
			reaction_time = maxf(reaction_time, _move_timer)
			await get_tree().create_timer(reaction_time).timeout
		if cube_option:
			await _aim_for_cube(cube_option.dir, cube_option.cell)
		else:
			await _react(other_runners)
		if runner.is_alive():
			set_physics_process(true)
			_reset_turn_timer()

##
## Starts running. Be sure to set the runner and the map before calling this.
## The bot takes control of the runner until he dies.
##
func start():
	runner.set_vision_area_scale(vision_scale)

	_max_straight_time = 1.0 + (2 * map.map_size + 1) / 6.0
	_reset_turn_timer()

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

func _reset_turn_timer():
	if behavior == BehaviorTrait.EPILEPTIC:
		_turn_timer = randf_range(1, 1.5)
	else:
		_turn_timer = randf_range(0.667, 1.333) * _max_straight_time

#
# Makes the runner change direction, jump and/or slide in response to the
# obstacles surrounding him.
#
func _react(other_runners: Array[Runner]):
	var options: Array[RunnerAction]
	var pos: Vector2
	var cell: Cell
	var priority: int
	var forward = runner.direction
	var left = _get_left_dir()
	var right = _get_right_dir()
	var dyslexic = (behavior == BehaviorTrait.DYSLEXIC and randi() % 25 == 0)

	# continue straight on?

	pos = _get_next_pos(forward)
	cell = map.get_cell_at_pos(pos)
	priority = _evaluate_move(forward, pos, cell, other_runners)
	_add_option_maybe(options, forward, cell, priority)

	# turn left?

	pos = _get_next_pos(left)
	cell = map.get_cell_at_pos(pos)
	priority = _evaluate_move(left, pos, cell, other_runners)
	if _add_option_maybe(options, left, cell, priority) and dyslexic:
		options.back().dir = right

	# turn right?

	pos = _get_next_pos(right)
	cell = map.get_cell_at_pos(pos)
	priority = _evaluate_move(right, pos, cell, other_runners)
	if _add_option_maybe(options, right, cell, priority) and dyslexic:
		options.back().dir = left

	# if there is nowhere to go, turn either left or right, which may then lead
	# to a u-turn

	if options.is_empty():
		_send_direction_event(left if randi() & 1 else right)
		return

	# if the exit door is there, move in the direction of the door, if
	# possible, otherwise pick an option at random

	var option: RunnerAction
	if _door_cell:
		option = await _pick_best_way_to_door(options)
		# can't reach the door? just keep going straight
		if option == null:
			option = options.front()
	elif _turn_timer <= 0.0:
		option = _pick_left_or_right(options)
		# can't turn? just keep going straight
		if option == null:
			option = options.front()
	else:
		option = options.pick_random()

	# jump or slide, if necessary, to avoid the obstacle in the next cell

	var jump_or_slide: StringName
	if option.cell == null or option.cell.get_state() in [
		Cell.State.LOWERED, Cell.State.HIDDEN
	]:
		jump_or_slide = &"jump"
	elif option.cell.get_state() == Cell.State.PYLON:
		jump_or_slide = &"slide"

	# finally, do it: change direction, if necessary, then jump or slide, maybe

	if option.dir != runner.direction:
		_send_direction_event(option.dir)

	if jump_or_slide:
		var swap = (behavior == BehaviorTrait.STUPID and randi() % 25 == 0)
		var time = _get_time_to_cell_border(option.dir) - jump_slide_runup_time
		if time > 0:
			await get_tree().create_timer(time).timeout
		if ((jump_or_slide == &"jump" and not swap) or
			(jump_or_slide == &"slide" and swap)):
			_send_action_event(&"ui_a_button")
		else:
			_send_action_event(&"ui_b_button")

#
# Adds a new RunnerAction to the options array, if priority > 0 and >= the
# priority of the options already in the array. If priority > the priority of
# the existing options, they are replaced.
#
# Returns true if option was added to the array.
#
func _add_option_maybe(
	options: Array[RunnerAction], dir: Vector2, cell: Cell, priority: int) -> bool:
	if priority == 0:
		return false

	if not options.is_empty():
		if options[0].priority > priority:
			return false
		if options[0].priority < priority:
			options.clear()

	var option = RunnerAction.new()
	option.dir = dir
	option.cell = cell
	option.priority = priority
	options.push_back(option)
	return true

#
# Given one or more options, pick one at random which is NOT to go straight, or
# null if that is the only option.
#
func _pick_left_or_right(options: Array[RunnerAction]):
	var candidates = options.duplicate()
	while not candidates.is_empty():
		var which = randi() % candidates.size()
		if Globals.compare_directions(candidates[which].dir, runner.direction):
			candidates.remove_at(which)
		else:
			return candidates[which]
	return null

#
# Given one or more options, once the exit door has appeared, pick one that
# best takes the runner in the direction of the door, if possible, or null if
# not.
#
# Note that this function may wait until the runner reaches the middle of the
# cell, or even turn first to position the runner in the cell, so make sure to
# await its finish.
#
func _pick_best_way_to_door(options: Array[RunnerAction]):
	if not (_door_cell and runner.get_current_cell()):
		return null

	var option: RunnerAction = null
	var curr_cell = runner.get_current_cell()
	var door_uv = Map.get_cell_index(_door_cell.global_position)
	var runner_uv = Map.get_cell_index(curr_cell.global_position)

	# aim for a cell next to the central cell, in the axis of the passageway;
	# once we get there, aim for the central cell itself

	var target_uv = door_uv
	var target_coord: StringName
	var door_axis = _door_cell.get_door().get_orientation()

	if door_axis == Door.Axis.SW_NE:
		target_coord = &"x"
		target_uv.y += 1 if target_uv.y < runner_uv.y else -1
	else:
		target_coord = &"y"
		target_uv.x += 1 if target_uv.x < runner_uv.x else -1

	if runner_uv == target_uv or runner_uv == door_uv:
		target_uv = door_uv

	# TODO: if the target cell contains an obstacle, abort!

	# which is the best direction to approach the target?

	var preferred_dir: Vector2

	# we are already in the central cell: just keep going straight

	if runner_uv == door_uv:
		preferred_dir = runner.direction

	# we have already reached the row or column in the axis of the passageway:
	# aim now for the door itself

	elif runner_uv[target_coord] == target_uv[target_coord]:
		if door_axis == Door.Axis.SW_NE:
			if target_uv.y > runner_uv.y:
				preferred_dir = Globals.NORTHEAST
			else:
				preferred_dir = Globals.SOUTHWEST
		else:
			if target_uv.x > runner_uv.x:
				preferred_dir = Globals.SOUTHEAST
			else:
				preferred_dir = Globals.NORTHWEST

	# otherwise: aim first for the row or column in the axis of the passageway

	elif runner_uv[target_coord] < target_uv[target_coord]:
		if door_axis == Door.Axis.SW_NE:
			preferred_dir = Globals.SOUTHEAST
		else:
			preferred_dir = Globals.NORTHEAST
	else:
		if door_axis == Door.Axis.SW_NE:
			preferred_dir = Globals.NORTHWEST
		else:
			preferred_dir = Globals.SOUTHWEST

	# is going in that direction an option? if not, abort

	for opt in options:
		if Globals.compare_directions(opt.dir, preferred_dir):
			option = opt
			break

	if option == null:
		return null

	# if we are already going in the right direction, but we are not in the
	# middle of the cell, turn left or right toward the middle, then turn again

	if Globals.compare_directions(option.dir, runner.direction):
		var left = _get_left_dir()
		var progress = _get_progress_within_cell(left)
		if progress < 0.3:
			if not _check_for_walls(_get_next_pos(left), null):
				_send_direction_event(left)
				var t = (Cell.side_length * (0.5 - progress)) / runner.get_current_speed()
				await get_tree().create_timer(t).timeout
		elif progress > 0.7:
			var right = -left
			if not _check_for_walls(_get_next_pos(right), null):
				_send_direction_event(right)
				var t = (Cell.side_length * (1.0 - progress)) / runner.get_current_speed()
				await get_tree().create_timer(t).timeout

	# if we are NOT going in the preferred direction, change direction once we
	# reach the center of the cell

	else:
		var progress = _get_progress_within_cell(runner.direction)
		if progress < 0.3:
			var t = Cell.side_length * (0.5 - progress) / runner.get_current_speed()
			await get_tree().create_timer(t).timeout

	return option

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
# such as a one-way sign (that is not pointing the wrong way) or a teleport.
#
# 2: The destination contains a hole that can be jumped over, or a pylon that
# can be slid under, or no obstacles at all.
#
func _evaluate_move(
	dir: Vector2, next_pos: Vector2, next_cell: Cell,
	other_runners: Array[Runner]) -> int:

	# is the runner headed for a wall?

	if _check_for_walls(next_pos, next_cell):
		return 0

	# is the runner headed for a hole in the map?

	if next_cell == null:
		return 2 if _can_jump_or_slide_over(next_pos, dir) else 0

	# special case for navigating the exit door

	if next_cell.get_door():
		return 2 if _is_parallel_to_door_axis(dir) else 0

	# is the runner headed toward another runner?

	var is_crowded = false
	for other in other_runners:
		if other.get_current_cell() == next_cell:
			is_crowded = true
			break

	# no obstacles in the next cell: we're done

	if _is_cell_clear(next_cell):
		return 1 if is_crowded else 2

	# otherwise it depends on what obstacle the cell contains

	match next_cell.get_state():
		Cell.State.LOWERED:
			if (next_cell.get_artefact() == null and
				_can_jump_or_slide_over(next_pos, dir)):
				return 2
		Cell.State.HIDDEN:
			if _can_jump_or_slide_over(next_pos, dir):
				return 2
		Cell.State.TELEPORT:
			return 1
		Cell.State.ONE_WAY:
			if not _is_one_way_lethal(dir, next_cell):
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
# Given a direction of movement, returns how long it will take the runner to
# get from his current position to the border of the current cell.
#
func _get_time_to_cell_border(dir: Vector2) -> float:
	var progress = _get_progress_within_cell(dir)
	return Cell.side_length * (1.0 - progress) / runner.get_current_speed()

#
# Given a direction of movement, and the runner's current position and cell,
# returns a value between 0 and 1 indicating his position within that cell. A
# value close to 0 indicates that he has most of the cell in front of him; a
# value close to 1 indicates that he will soon exit the cell.
#
func _get_progress_within_cell(dir: Vector2) -> float:
	var cell = runner.get_current_cell()
	var uv = cell.get_local_uv(cell.to_local(runner.global_position))
	match Globals.dir_to_axis(dir):
		Globals.Axis.NW:
			return 1.0 - uv.x
		Globals.Axis.NE:
			return uv.y
		Globals.Axis.SW:
			return 1.0 - uv.y
		Globals.Axis.SE:
			return uv.x
	return 0

#
# Given a direction of movement and a cell containing a one-way obstacle,
# returns true if the one-way sign is pointing in the opposite direction.
#
func _is_one_way_lethal(dir: Vector2, cell: Cell) -> bool:
	var runner_axis = Globals.dir_to_axis(dir)
	match cell.get_one_way_direction():
		Globals.Axis.NW:
			return runner_axis == Globals.Axis.SE
		Globals.Axis.NE:
			return runner_axis == Globals.Axis.SW
		Globals.Axis.SW:
			return runner_axis == Globals.Axis.NE
		Globals.Axis.SE:
			return runner_axis == Globals.Axis.NW
	return true

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
	_move_timer = min_move_interval

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
# Returns true if the given direction vector is parallel to the exit door
# passageway, false if it is perpendicular.
#
func _is_parallel_to_door_axis(dir: Vector2) -> bool:
	if _door_cell:
		var runner_axis = Globals.dir_to_axis(dir)
		match _door_cell.get_door().get_orientation():
			Door.Axis.SW_NE:
				return runner_axis in [Globals.Axis.NE, Globals.Axis.SW]
			Door.Axis.NW_SE:
				return runner_axis in [Globals.Axis.NW, Globals.Axis.SE]
	return true

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

#
# Looks for cubes in the cells ahead of the runner and to his left and right.
# If any are found, and are of interest to the runner, and are accessible to
# the runner, the appropriate actions are returned.
#
func _look_for_neighboring_cube(
	forward_cell: Cell, other_runners: Array[Runner]) -> RunnerAction:
	var cube_options: Array[RunnerAction]

	# check for a cube straight ahead (and assume the caller has already
	# determined that there are no obstacles)

	if forward_cell:
		var cube = forward_cell.get_cube()
		if cube and _wants_bonus(cube.get_bonus()):
			var option = RunnerAction.new()
			option.cell = forward_cell
			option.dir = runner.direction
			cube_options.append(option)

	# check for cubes and obstacles to the left and right

	for dir in [_get_left_dir(), _get_right_dir()]:
		var next_pos = _get_next_pos(dir)
		var next_cell = map.get_cell_at_pos(next_pos)
		if next_cell:
			var cube = next_cell.get_cube()
			if (cube and _wants_bonus(cube.get_bonus()) and
				_evaluate_move(dir, next_pos, next_cell, other_runners) == 2):
				var option = RunnerAction.new()
				option.cell = next_cell
				option.dir = dir
				cube_options.append(option)

	return cube_options.pick_random() if cube_options else null

#
# Aim for the cube which is found in the neighboring cell in the given
# direction.
#
func _aim_for_cube(dir: Vector2, cube_cell: Cell):
	var cube = cube_cell.get_cube()
	if cube == null:
		return

	var cube_uv = cube_cell.get_local_uv(cube.position)
	var curr_cell = runner.get_current_cell()
	var local_pos = curr_cell.to_local(runner.global_position)
	var runner_uv = curr_cell.get_local_uv(local_pos)

	# if the cube is in the direction we are moving already, turn left then
	# right, or right then left, to line up with the cube

	if Globals.compare_directions(dir, runner.direction):
		var tmpdir: Vector2
		var delta: float
		match Globals.dir_to_axis(runner.direction):
			Globals.Axis.NW, Globals.Axis.SE:
				delta = cube_uv.y - runner_uv.y
				if delta >= 0:
					tmpdir = Globals.NORTHEAST
				else:
					delta *= -1
					tmpdir = Globals.SOUTHWEST
			Globals.Axis.NE, Globals.Axis.SW:
				delta = cube_uv.x - runner_uv.x
				if delta >= 0:
					tmpdir = Globals.SOUTHWEST
				else:
					delta *= -1
					tmpdir = Globals.NORTHWEST
		if delta > 0.1:
			_send_direction_event(tmpdir)
			var t = Cell.side_length * delta / runner.get_current_speed()
			await get_tree().create_timer(t).timeout
			_send_direction_event(dir)

	# otherwise, wait until we reach the level of the cube before turning left
	# or right

	else:
		var delta: float
		match Globals.dir_to_axis(runner.direction):
			Globals.Axis.NW:
				delta = runner_uv.x - cube_uv.x
			Globals.Axis.NE:
				delta = cube_uv.y - runner_uv.y
			Globals.Axis.SW:
				delta = runner_uv.y - cube_uv.y
			Globals.Axis.SE:
				delta = cube_uv.x - runner_uv.x
		if delta > 0:
			var t = Cell.side_length * delta / runner.get_current_speed()
			await get_tree().create_timer(t).timeout
		_send_direction_event(dir)

#
# Returns true if the runner is interested in the given bonus/malus.
#
func _wants_bonus(_bonus: Bonus) -> bool:
	# TODO
	return false

##
## Applies the given sensory trait to the bot. Note that the effects are
## cumulative, if you call this function more than once, which you probably do
## not want to do.
##
func apply_sensory_trait(st: SensoryTrait):
	match st:
		SensoryTrait.VISIONARY:
			vision_scale *= 1.5
		SensoryTrait.MYOPIC:
			vision_scale *= 0.667
		SensoryTrait.REACTIVE:
			min_reaction_time -= 0.05
			max_reaction_time -= 0.05
		SensoryTrait.SLOW:
			min_reaction_time += 0.05
			max_reaction_time += 0.05
		SensoryTrait.CLUMSY:
			min_move_interval += 0.05
		SensoryTrait.DEXTEROUS:
			min_move_interval -= 0.05
