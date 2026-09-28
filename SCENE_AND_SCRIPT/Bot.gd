class_name Bot extends Node

var runner: Runner: set = set_runner
var map: Map
var start_corner: Globals.Corner

var _next_cell: Cell
var _block_commands: bool = false

func _ready():
	set_physics_process(false)
	runner.died.connect(func(): set_physics_process(false))

func _physics_process(_delta: float):
	if _block_commands:
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

func start():
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
	if not _block_commands:
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

	_block_commands = true
	await get_tree().create_timer(3.0/60.0, true, true).timeout
	_block_commands = false

func _send_action_event(action: StringName):
	var event = InputEventAction.new()
	if runner.input_device >= 0:
		event.device = runner.input_device
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().create_timer(2.0/60.0, true, true).timeout
	event.pressed = false
	Input.parse_input_event(event)

func _is_cell_clear(cell: Cell) -> bool:
	return (cell and cell.get_state() == Cell.State.NORMAL
			and not (cell.has_wall() or cell.get_artefact()))
