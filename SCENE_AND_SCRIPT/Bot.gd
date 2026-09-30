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

## After taking action, the bot will wait at least thing long before taking
## another.
const min_move_interval: float = 0.1

## When the bot makes a u-turn, this is the time interval between the two turns.
const u_turn_interval: float = 0.1

## How long before reaching a hole or a pylon the runner should jump or slide.
const jump_slide_runup_time: float = 0.05

func _ready():
	set_physics_process(false)
	runner.died.connect(func(): set_physics_process(false))

func _physics_process(_delta: float):
	var next_pos = _get_next_pos(runner.direction)
	var next_cell = map.get_cell_at_pos(next_pos)
	if runner.get_visible_runners() or not _is_cell_clear(next_cell):
		var t = randf_range(min_reaction_time, max_reaction_time)
		set_physics_process(false)
		await get_tree().create_timer(t).timeout
		_turn()
		set_physics_process(not (runner.is_dead or runner.is_falling))

#
# Given a point outside the current cell, in the direction the runner is moving,
# returns how long in seconds it will take the runner to get from his current
# position to the border of the current cell.
#
func _get_time_to_cell_border(next_pos: Vector2) -> float:
	if runner.current_cell:
		var pt = runner.current_cell.get_exit_point(
			runner.global_position, next_pos)
		if pt != null:
			return runner.global_position.distance_to(pt) / runner.get_current_speed()
	return 0

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

func _get_next_pos(dir: Vector2) -> Vector2:
	var pos = runner.global_position
	pos.x += (0.5 if dir.x > 0 else -0.5) * Cell.width
	pos.y += (0.5 if dir.y > 0 else -0.5) * Cell.height
	return pos

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

func _turn():
	var dir1 = _get_left_dir()
	var dir2 = _get_right_dir()
	var pos1 = _get_next_pos(dir1)
	var pos2 = _get_next_pos(dir2)
	var cell1 = map.get_cell_at_pos(pos1)
	var cell2 = map.get_cell_at_pos(pos2)
	var ok1 = _is_cell_clear(cell1)
	var ok2 = _is_cell_clear(cell2)
	var dir: Vector2

	if ok1 and ok2:
		dir = dir1 if randi() & 1 else dir2
	elif ok1:
		dir = dir1
	elif ok2:
		dir = dir2

	if ok1 or ok2:
		if dir.x > 0:
			if dir.y > 0:
				_send_direction_event(Globals.SOUTHEAST)
			else:
				_send_direction_event(Globals.NORTHEAST)
		else:
			if dir.y > 0:
				_send_direction_event(Globals.SOUTHWEST)
			else:
				_send_direction_event(Globals.NORTHWEST)
	else:
		_send_direction_event(dir1 if randi() & 1 else dir2)
		await get_tree().create_timer(u_turn_interval).timeout
		_send_direction_event(-runner.direction)

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

func _is_cell_clear(cell: Cell) -> bool:
	return (cell
			and cell.get_state() in [Cell.State.NORMAL, Cell.State.CUBE]
			and cell.get_wall_count() < 2
			and not cell.get_artefact())
