@tool
class_name Map extends Node2D

@export_range(1, 10) var map_size: int = 4:
	set(size):
		if map_size != size:
			map_size = size
			_build_map()

@export var slide_speed: float = 9

var _cell_scene := preload("res://SCENE_AND_SCRIPT/Cell.tscn")
var _door_scene := preload("res://SCENE_AND_SCRIPT/Door.tscn")

const _cell_offset_x = 236.0
const _cell_offset_y = 118.0
const _southeast = 0.5 * Vector2(_cell_offset_x, _cell_offset_y)
const _northeast = 0.5 * Vector2(_cell_offset_x, -_cell_offset_y)

var _cells: Dictionary[Vector2i, Cell]
var _center_cell: Cell

enum ObstacleType {
	ROW_SLIDE,
	COLUMN_SLIDE,
	CELL_LOWER,
	CELL_HIDE,
	CELL_ONE_WAY,
	CELL_BUG1,
	CELL_BUG2,
	PYLON_LOWER,
	PYLON_DROP,
	CENTER_LOWER
}

class ObstacleEvent extends RefCounted:
	var type: ObstacleType
	var is_undo: bool = false
	var cell: Cell

var _pending_events: Array[ObstacleEvent]
var _is_sliding: bool = false
var _timer: Timer

func _ready():
	_build_map()

	if Engine.is_editor_hint():
		return

	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_on_obstacle_timer_timeout)
	_timer.start(5 - (mini(5, Globals.difficulty) - 1) / 2.0)

	var center_time = 6 * (2 * Globals.map_size + 1 + 2 * Globals.difficulty)
	var center_timer = get_tree().create_timer(center_time)
	center_timer.timeout.connect(_lower_center_cell)

func _build_map():
	var parent: Node2D = self

	for cell in _cells.values():
		parent.remove_child(cell)
		cell.queue_free()

	_cells.clear()

	# center

	_center_cell = _add_cell(parent, Vector2i(0, 0), Cell.Decoration.CENTER)

	# corners

	_add_cell(parent, Vector2i(-map_size, map_size), Cell.Decoration.N)
	_add_cell(parent, Vector2i(map_size, -map_size), Cell.Decoration.S)
	_add_cell(parent, Vector2i(-map_size, -map_size), Cell.Decoration.W)
	_add_cell(parent, Vector2i(map_size, map_size), Cell.Decoration.E)

	# edges

	_build_edge(parent, Globals.Axis.NW)
	_build_edge(parent, Globals.Axis.NE)
	_build_edge(parent, Globals.Axis.SW)
	_build_edge(parent, Globals.Axis.SE)

	# interior

	var interior_cell_count = 2 * map_size - 1
	var middle_cell = map_size - 1
	var deco_options = [0, 1, 2, 3, 4, 5, 6, 7]
	var decos = []

	for x in interior_cell_count:
		decos.append([])
		for y in interior_cell_count:
			if x == middle_cell and y == middle_cell:
				decos[x].append(0)
			else:
				var candidates = deco_options.duplicate()
				if x > 0 and x-1 != middle_cell:
					candidates.erase(decos[x-1][y])
				if y > 0 and y-1 != middle_cell:
					candidates.erase(decos[x][y-1])
				decos[x].append(candidates.pick_random())
				var uv = Vector2i(-map_size + x+1, -map_size + y+1)
				var deco = Cell.Decoration.OTHER1 + decos[x][y]
				_add_cell(parent, uv, deco as Cell.Decoration)

func _build_edge(parent: Node2D, edge: Globals.Axis):
	var uv0: Vector2i
	var uvd: Vector2i
	var deco1: Cell.Decoration

	match edge:
		Globals.Axis.NW:
			uv0 = Vector2i(-map_size, -map_size + 1)
			uvd = Vector2i(0, 1)
			deco1 = Cell.Decoration.NW1
		Globals.Axis.NE:
			uv0 = Vector2i(-map_size + 1, map_size)
			uvd = Vector2i(1, 0)
			deco1 = Cell.Decoration.NE1
		Globals.Axis.SW:
			uv0 = Vector2i(map_size - 1, -map_size)
			uvd = Vector2i(-1, 0)
			deco1 = Cell.Decoration.SW1
		Globals.Axis.SE:
			uv0 = Vector2i(map_size, map_size - 1)
			uvd = Vector2i(0, -1)
			deco1 = Cell.Decoration.SE1

	var edge_cell_count = 2 * map_size - 1
	var deco_offset = randi() % 3

	for i in edge_cell_count:
		var uv: Vector2i = uv0 + i * uvd
		var deco = deco1 + deco_offset
		deco_offset = (deco_offset + randi_range(1, 2)) % 3
		_add_cell(parent, uv, deco as Cell.Decoration)

#
# Creates a new cell at the given position and with the given decoration.
#
func _add_cell(parent: Node2D, uv: Vector2i, deco: Cell.Decoration) -> Cell:
	var cell: Cell = _cell_scene.instantiate()
	cell.position = _get_cell_pos(uv)
	cell.decoration = deco
	parent.add_child(cell)
	_cells[uv] = cell
	return cell

#
# Returns the position in XY coordinates of the cell at the given UV index,
# where U corresponds to the NW-SE axis, V corresponds to the SW-NE axis, and
# UV (0,0) is the origin of the map. The given cell may or may not actually
# exist.
#
static func _get_cell_pos(uv: Vector2i) -> Vector2:
	return uv.x * _southeast + uv.y * _northeast

func _lower_cell(cell: Cell):
	Sounds.play_cell_up_down()
	await get_tree().create_timer(0.5).timeout
	await cell.lower()
	Sounds.stop_cell_up_down()

func _raise_cell(cell: Cell):
	await cell.raise()

func _hide_cell(cell: Cell):
	Sounds.play_cell_disappearing()
	await get_tree().create_timer(0.5).timeout
	await cell.disappear()

func _show_cell(cell: Cell):
	await cell.reappear()

func _start_cell_one_way(cell: Cell, dir: Globals.Axis):
	cell.start_one_way(dir)

func _stop_cell_one_way(cell: Cell):
	cell.stop_one_way()

func _start_cell_bug1(cell: Cell):
	cell.start_bug1()

func _stop_cell_bug1(cell: Cell):
	cell.stop_bug1()

func _start_cell_bug2(cell: Cell):
	cell.start_bug2()

func _stop_cell_bug2(cell: Cell):
	cell.stop_bug2()

#
# Slides the given column (u) the given number of cells to the right (if
# distance is positive) or to the left (if negative).
#
func _slide_column(u: int, distance: int):
	await _slide(&"x", u, distance)

#
# Slides the given row (v) the given number of cells upward (if distance is
# positive) or downward (if negative).
#
func _slide_row(v: int, distance: int):
	await _slide(&"y", v, distance)

#
# Does the work for _slide_column() and _slide_row(). The axis parameter must
# be either "x" (for a column) or "y" (for a row), and index is the index of
# the column or row.
#
func _slide(axis: StringName, index: int, distance: int):

	# which cells are affected?

	var column_keys: Array[Vector2i]

	for uv in _cells:
		if uv[axis] == index:
			column_keys.append(uv)

	if column_keys.is_empty() or distance == 0:
		return

	# start sound effects

	Sounds.play_cell_slide()
	await get_tree().create_timer(1).timeout

	for key in column_keys:
		var cell: Cell = _cells[key]
		cell.start_sliding()

	var any_cell: Cell = _cells.values().front()
	var pause: float = any_cell.get_sliding_animation_start_length()
	await get_tree().create_timer(pause).timeout

	# use a Tween to do the sliding and update cells' locations

	var updated_cells: Dictionary[Vector2i, Cell]
	var other_axis = &"x" if axis == &"y" else &"y"
	var duration = absf(slide_speed * distance)
	var tween: Tween = create_tween().set_parallel()

	for key in column_keys:
		var cell: Cell = _cells[key]
		var new_key: Vector2i = key
		new_key[other_axis] += distance
		tween.tween_property(cell, ^":position", _get_cell_pos(new_key), duration)
		_cells.erase(key)
		updated_cells[new_key] = cell

	await tween.finished
	_cells.merge(updated_cells)

	# stop sound effects

	for cell in updated_cells.values():
		cell.stop_sliding()

	pause = any_cell.get_sliding_animation_stop_length()
	await get_tree().create_timer(pause).timeout

	Sounds.stop_cell_slide()

func _lower_pylon(cell: Cell):
	var pylon: Pylon = cell.add_pylon()
	if pylon:
		await pylon.lower()

func _raise_pylon(cell: Cell):
	var pylon: Pylon = cell.get_pylon()
	if pylon:
		await pylon.raise()
		cell.remove_pylon()

func _drop_pylon(cell: Cell):
	var pylon: Pylon = cell.add_pylon()
	if pylon:
		await pylon.drop()

func _undrop_pylon(cell: Cell):
	var pylon: Pylon = cell.get_pylon()
	if pylon:
		await pylon.undrop()
		cell.remove_pylon()

#
# Handles an ObstacleEvent, which creates or removes an obstacle. Slide events
# are special in two ways: they are permanent, so there is no corresponding
# "undo" event; and no new obstacles are generated while the row or column is
# sliding. (We COULD continue to generate obstacles that are not on the row or
# column that is sliding, but we don't.) Events that arrive while a slide is in
# progress are blocked until the slide finishes.
#
func _handle_obstacle_event(event: ObstacleEvent):
	if _is_sliding:
		_pending_events.append(event)
		return

	match event.type:
		ObstacleType.ROW_SLIDE, ObstacleType.COLUMN_SLIDE:
			@warning_ignore("integer_division")
			var max_dist = (2 * map_size + 1) / 3
			var dist = randi_range(1, 2 * max_dist)
			if dist > max_dist:
				dist = -(dist - max_dist)
			_timer.paused = true
			_is_sliding = true
			if event.type == ObstacleType.ROW_SLIDE:
				await _slide_row(_pick_random_row(), dist)
			else:
				await _slide_column(_pick_random_column(), dist)
			_is_sliding = false
			for ev in _pending_events:
				_handle_obstacle_event(ev)
			_pending_events.clear()
			_timer.paused = false

		ObstacleType.CELL_LOWER:
			if event.is_undo:
				_raise_cell(event.cell)
			else:
				event.cell = _pick_random_cell()
				await _lower_cell(event.cell)
				_schedule_undo_event(event)

		ObstacleType.CELL_ONE_WAY:
			if event.is_undo:
				_stop_cell_one_way(event.cell)
			else:
				var dir = Globals.Axis.values().pick_random()
				event.cell = _pick_random_cell()
				_start_cell_one_way(event.cell, dir)
				_schedule_undo_event(event)

		ObstacleType.CELL_BUG1:
			if event.is_undo:
				_stop_cell_bug1(event.cell)
			else:
				event.cell = _pick_random_cell()
				_start_cell_bug1(event.cell)
				_schedule_undo_event(event)

		ObstacleType.CELL_BUG2:
			if event.is_undo:
				_stop_cell_bug2(event.cell)
			else:
				event.cell = _pick_random_cell()
				_start_cell_bug2(event.cell)
				_schedule_undo_event(event)

		ObstacleType.PYLON_LOWER:
			if event.is_undo:
				_raise_pylon(event.cell)
			else:
				event.cell = _pick_random_cell()
				await _lower_pylon(event.cell)
				_schedule_undo_event(event)

		ObstacleType.PYLON_DROP:
			if event.is_undo:
				_undrop_pylon(event.cell)
			else:
				event.cell = _pick_random_cell()
				await _drop_pylon(event.cell)
				_schedule_undo_event(event)

		ObstacleType.CENTER_LOWER:
			await _center_cell.lower()
			await get_tree().create_timer(2 * Globals.difficulty).timeout
			_center_cell.add_child(_door_scene.instantiate())

#
# Schedules an obstacle event to undo the creation of an obstacle at the given
# cell.
#
func _schedule_undo_event(event: ObstacleEvent):
	await get_tree().create_timer(_get_obstacle_duration()).timeout
	var undo_event: ObstacleEvent = ObstacleEvent.new()
	undo_event.type = event.type
	undo_event.cell = event.cell
	undo_event.is_undo = true
	_handle_obstacle_event(undo_event)

#
# The duration of an obstacle is between 5 and 20 seconds, depending on the
# difficulty setting.
#
func _get_obstacle_duration() -> float:
	return 5 + 15 * (mini(5, Globals.difficulty) - 1) / 4.0

#
# Picks and returns a random row of the map for sliding.
#
func _pick_random_row() -> int:
	var candidates = {}
	for uv in _cells.keys():
		candidates[uv.y] = true
	return candidates.keys().pick_random()

#
# Picks and returns a random column of the map for sliding.
#
func _pick_random_column() -> int:
	var candidates = {}
	for uv in _cells.keys():
		candidates[uv.x] = true
	return candidates.keys().pick_random()

#
# Picks a cell at random, except that some cells are excluded: the center cell
# and any cells that have been lowered, hidden, bugged, etc., or that have
# pylons on them.
#
func _pick_random_cell() -> Cell:
	var candidates = []
	for cell in _cells.values():
		if not (cell.is_center() or cell.is_busy() or cell.get_pylon()):
			candidates.append(cell)
	return candidates.pick_random()

#
# Generates a new obstacle when the timer goes off.
#
func _on_obstacle_timer_timeout():
	var event: ObstacleEvent = ObstacleEvent.new()
	event.type = ObstacleType.values().pick_random()
	_handle_obstacle_event(event)

#
# Lowers the center (404) cell. We use an ObstacleEvent here, rather than
# lowering the cell directly, in case a row or column is sliding.
#
func _lower_center_cell():
	var event: ObstacleEvent = ObstacleEvent.new()
	event.type = ObstacleType.CENTER_LOWER
	_handle_obstacle_event(event)
