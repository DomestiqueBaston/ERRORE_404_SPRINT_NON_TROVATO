@tool
class_name Map extends Node2D

## The actual length of one side of the map is 2 * map_size + 1 cells.
@export_range(1, 10) var map_size: int = 4:
	set(size):
		if map_size != size:
			map_size = size
			_build_map()

## How long it takes for a row or column to slide a distance of one cell, in
## seconds.
@export var slide_time: float = 9

var _cell_scene := preload("res://SCENE_AND_SCRIPT/Cell.tscn")

const _cell_step_x = 0.5 * Cell.width
const _cell_step_y = 0.5 * Cell.height

# The X coordinate of the rightmost cell (the eastern corner).
var _xmax: float

# The "404" cell at the center of the map (which may not actually be at the
# center if rows or columns have been sliding around).
var _center_cell: Cell

# All cells in the map, with their current locations (except while sliding).
var _cells: Dictionary[Vector2i, Cell]

# Cells that are available to be turned into obstacles (not the "center" cell
# or cells that are already obstacles).
var _available_cells: Array[Cell]

# Cells that are now obstacles: this is necessary because some obstacles can
# be "canceled" (removed before their time has lapsed), so removing them from
# this array is the most reliable way of determining whether they are still
# around or not.
var _obstacle_cells: Array[Cell]

enum ObstacleType {
	ROW_SLIDE,
	COLUMN_SLIDE,
	CELL_LOWER,
	CELL_HIDE,
	CELL_ONE_WAY,
	CELL_TELEPORT1,
	CELL_TELEPORT2,
	PYLON_LOWER,
	PYLON_DROP,
	# only events above this line are generated randomly
	_RANDOM_,
	REMOVE_ARTEFACT
}

class ObstacleEvent extends RefCounted:
	var type: ObstacleType
	# false when putting an obstacle in place, true when removing it afterward
	var is_undo: bool = false
	# for undo events in particular: the cell containing the obstacle
	var cell: Cell
	# for teleport events only: the other cell
	var cell2: Cell

	func _init(event_type: ObstacleType):
		type = event_type

# Events that have been blocked until a row or column finishes sliding.
var _pending_events: Array[ObstacleEvent]

enum SlideState {
	NONE,
	ROW,
	COLUMN
}

var _slide_state: SlideState = SlideState.NONE
var _slide_index: int

var _timer: Timer

func _ready():
	_build_map()

	if Engine.is_editor_hint():
		return

	# all cells except the central cell are available for obstacles initially

	_available_cells = _cells.values().duplicate()
	_available_cells.erase(_center_cell)
	_obstacle_cells.clear()

	# lower central cell and add artefact above it

	_center_cell.lower(true)
	_center_cell.add_artefact()

	_timer = Timer.new()
	add_child(_timer)
	_timer.timeout.connect(_on_obstacle_timer_timeout)
	_timer.start(5 - (mini(5, Globals.difficulty) - 1) / 2.0)

	var center_time = 6 * (2 * Globals.map_size + 1 + 2 * Globals.difficulty)
	var center_timer = get_tree().create_timer(center_time)
	center_timer.timeout.connect(_on_center_timer_timeout)

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
	var east_corner: Cell = \
		_add_cell(parent, Vector2i(map_size, map_size), Cell.Decoration.E)
	_xmax = east_corner.position.x

	# edges

	_build_edge(parent, Globals.Axis.NW)
	_build_edge(parent, Globals.Axis.NE)
	_build_edge(parent, Globals.Axis.SW)
	_build_edge(parent, Globals.Axis.SE)

	# interior

	var interior_cell_count = 2 * map_size - 1
	var middle_cell = map_size - 1
	var deco_options = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
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
	cell.position = get_cell_pos(uv)
	cell.decoration = deco
	cell.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	parent.add_child(cell)
	_cells[uv] = cell
	return cell

##
## Returns the position in XY coordinates of the cell at the given UV index,
## where U corresponds to the NW-SE axis, V corresponds to the SW-NE axis, and
## UV (0,0) is the origin of the map. The given cell need not actually exist.
##
## Note that this position is not valid while a cell is sliding from one
## location to another.
##
static func get_cell_pos(uv: Vector2i) -> Vector2:
	return Vector2(
		(uv.x + uv.y) * _cell_step_x,
		(uv.x - uv.y) * _cell_step_y)

##
## Does the inverse of get_cell_pos(): returns the UV index of the cell at the
## given position in XY coordinates. The cell need not actually exist.
##
static func get_cell_index(pos: Vector2) -> Vector2i:
	var y = 2.0 * pos.y
	return Vector2i(
		roundi((pos.x + y) / Cell.width),
		roundi((pos.x - y) / Cell.width))

##
## Returns the cell at the given UV index, where U corresponds to the NW-SE
## axis, V corresponds to the SW-NE axis, and UV (0,0) is the origin of the map.
## Returns null if there is no cell at the given index.
##
func get_cell_at(uv: Vector2i) -> Cell:
	return _cells.get(uv)

##
## Returns the cell that overlaps with the given collider, or null if there is
## none. Note that this works only if cell colliders are monitorable; at the
## moment they are NOT, because get_cell_as_pos() is used instead of this
## method, and it doesn't require them to be monitorable.
##
func get_cell_in_area(collider: Area2D) -> Cell:
	var first_cell: Cell = null

	for area in collider.get_overlapping_areas():
		var cell = Cell.get_cell_from_collider(area)
		if cell:
			# prefer non-normal cells in order to detect obstacles ASAP
			if cell.get_state() != Cell.State.NORMAL:
				return cell
			if first_cell == null:
				first_cell = cell

	return first_cell

##
## Returns the cell found at the given point, in global coordinates, or null if
## there is none.
##
func get_cell_at_pos(pos: Vector2) -> Cell:
	var params = PhysicsPointQueryParameters2D.new()
	params.position = pos
	params.collide_with_areas = true
	params.collide_with_bodies = false
	params.collision_mask = Globals.MAP_LAYER

	for result in get_world_2d().direct_space_state.intersect_point(params):
		if result.collider is Area2D:
			var cell = Cell.get_cell_from_collider(result.collider)
			if cell:
				return cell

	return null

##
## Returns the cell at the center of the map ("404"). Note that the cell may
## not actually be at the center anymore, if any rows or columns have slid.
##
func get_center_cell() -> Cell:
	return _center_cell

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
	await cell.start_one_way(dir)

func _stop_cell_one_way(cell: Cell):
	await cell.stop_one_way()

func _start_cell_teleport(event: ObstacleEvent):
	var type = 1 if event.type == ObstacleType.CELL_TELEPORT1 else 2
	event.cell.start_teleport(type)
	await event.cell2.start_teleport(type)

func _stop_cell_teleport(event: ObstacleEvent):
	event.cell.stop_teleport()
	await event.cell2.stop_teleport()

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

	# which cells are affected? wait for them to stop moving

	var column_keys: Array[Vector2i]

	for uv in _cells:
		if uv[axis] == index:
			column_keys.append(uv)
			await _cells[uv].wait_until_stationary()

	if column_keys.is_empty():
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
	var duration = absf(slide_time * distance)
	var tween: Tween = create_tween().set_parallel()

	for key in column_keys:
		var cell: Cell = _cells[key]
		var new_key: Vector2i = key
		new_key[other_axis] += distance
		var new_pos: Vector2 = get_cell_pos(new_key)
		tween.tween_property(cell, ^":position", new_pos, duration)
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
	await cell.lower_pylon()

func _raise_pylon(cell: Cell):
	await cell.raise_pylon()

func _drop_pylon(cell: Cell):
	await cell.drop_pylon()

func _undrop_pylon(cell: Cell):
	await cell.undrop_pylon()

#
# Handles an ObstacleEvent, which creates or removes an obstacle. Slide events
# are special in two ways: they are permanent, so there is no corresponding
# "undo" event; and no new obstacles are generated while the row or column is
# sliding. (We COULD continue to generate obstacles that are not on the row or
# column that is sliding, but we don't.) Events that may enter in conflict with
# the slide in progress are blocked until the slide finishes.
#
func _handle_obstacle_event(event: ObstacleEvent):

	# If a row or column is sliding, block events until the slide finishes,
	# with some exceptions. If the event concerns a specific cell (undo/remove
	# an obstacle or lower the center cell), and that cell is not affected by
	# the slide, then the event can go on. Also, there is no need to block the
	# removal of teleport or one-way obstacles; they do not touch the position
	# of the top of the cell, so there is no potential conflict with the slide
	# animation.

	if _slide_state != SlideState.NONE:
		var block: bool
		if event.type in [
			ObstacleType.CELL_TELEPORT1,
			ObstacleType.CELL_TELEPORT2,
			ObstacleType.CELL_ONE_WAY
		]:
			block = false
		elif event.cell:
			var uv: Vector2i = get_cell_index(event.cell.position)
			if _slide_state == SlideState.ROW:
				block = (uv.y == _slide_index)
			else:
				block = (uv.x == _slide_index)
		else:
			block = true
		if block:
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
			if event.type == ObstacleType.ROW_SLIDE:
				_slide_state = SlideState.ROW
				_slide_index = _pick_random_row()
				await _slide_row(_slide_index, dist)
			else:
				_slide_state = SlideState.COLUMN
				_slide_index = _pick_random_column()
				await _slide_column(_slide_index, dist)
			_slide_state = SlideState.NONE
			for ev in _pending_events:
				_handle_obstacle_event(ev)
			_pending_events.clear()
			_timer.paused = false

		ObstacleType.CELL_LOWER:
			if not event.is_undo:
				event.cell = _pick_random_cell()
				await _lower_cell(event.cell)
				_schedule_undo_event(event)
			elif _remove_obstacle(event.cell):
				await _raise_cell(event.cell)
				_available_cells.append(event.cell)

		ObstacleType.CELL_HIDE:
			if not event.is_undo:
				event.cell = _pick_random_cell()
				await _hide_cell(event.cell)
				_schedule_undo_event(event)
			elif _remove_obstacle(event.cell):
				await _show_cell(event.cell)
				_available_cells.append(event.cell)

		ObstacleType.CELL_ONE_WAY:
			if not event.is_undo:
				var dir = Globals.Axis.values().pick_random()
				event.cell = _pick_random_cell()
				await _start_cell_one_way(event.cell, dir)
				_schedule_undo_event(event)
			# obstacle may have been removed already if a runner ran into it!
			elif _remove_obstacle(event.cell):
				await _stop_cell_one_way(event.cell)
				_available_cells.append(event.cell)

		ObstacleType.CELL_TELEPORT1, ObstacleType.CELL_TELEPORT2:
			if not event.is_undo:
				event.cell = _pick_random_cell()
				event.cell2 = _pick_distant_random_cell(event.cell)
				if event.cell2:
					event.cell.set_teleport_partner(event.cell2)
					await _start_cell_teleport(event)
					_schedule_undo_event(event)
				elif _remove_obstacle(event.cell):
					_available_cells.append(event.cell)
			# obstacle may have been removed already if a runner ran into it!
			elif _remove_obstacle(event.cell):
				if _remove_obstacle(event.cell2):
					await _stop_cell_teleport(event)
					event.cell.reset_teleport_partner()
					_available_cells.append(event.cell2)
				_available_cells.append(event.cell)

		ObstacleType.PYLON_LOWER:
			if not event.is_undo:
				event.cell = _pick_random_cell()
				await _lower_pylon(event.cell)
				_schedule_undo_event(event)
			elif _remove_obstacle(event.cell):
				await _raise_pylon(event.cell)
				_available_cells.append(event.cell)

		ObstacleType.PYLON_DROP:
			if not event.is_undo:
				event.cell = _pick_random_cell()
				await _drop_pylon(event.cell)
				_schedule_undo_event(event)
			elif _remove_obstacle(event.cell):
				await _undrop_pylon(event.cell)
				_available_cells.append(event.cell)

		ObstacleType.REMOVE_ARTEFACT:
			_remove_artefact()

#
# Schedules an obstacle event to undo the creation of an obstacle at the given
# cell.
#
func _schedule_undo_event(event: ObstacleEvent):
	await get_tree().create_timer(_get_obstacle_duration()).timeout
	var undo_event: ObstacleEvent = ObstacleEvent.new(event.type)
	undo_event.cell = event.cell
	undo_event.cell2 = event.cell2
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
# Picks an "available" cell at random (a cell that is not the center cell, has
# not been lowered, hidden, made one-way, etc., and does not have a pylon on
# it). The cell is removed from the array of available cells, added to the
# array of obstance cells, and returned.
#
func _pick_random_cell() -> Cell:
	var index = randi() % _available_cells.size()
	var cell = _available_cells.pop_at(index)
	_obstacle_cells.append(cell)
	return cell

#
# Like _pick_random_cell(), but picks a cell that is more than a certain
# distance from cell1.
#
func _pick_distant_random_cell(cell1: Cell) -> Cell:
	var cell2: Cell = null
	var uv1: Vector2i = get_cell_index(cell1.position)
	var mindist: int = map_size * map_size
	var failures: Array[Cell]
	while _available_cells and not cell2:
		var other: Cell = _pick_random_cell()
		var uv2: Vector2i = get_cell_index(other.position)
		if uv2.distance_squared_to(uv1) >= mindist:
			cell2 = other
		else:
			failures.append(other)
	for cell in failures:
		_available_cells.append(cell)
		_obstacle_cells.erase(cell)
	return cell2

func _remove_obstacle(cell: Cell) -> bool:
	var index = _obstacle_cells.find(cell)
	if index < 0:
		return false
	else:
		_obstacle_cells.remove_at(index)
		return true

#
# Generates a new obstacle when the timer goes off.
#
func _on_obstacle_timer_timeout():
	# we make CELL_ONE_WAY twice as likely to appear as the others, because the
	# other event types are all in pairs...
	var type = randi() % (ObstacleType._RANDOM_ + 1)
	if type == ObstacleType._RANDOM_:
		type = ObstacleType.CELL_ONE_WAY
	var event = ObstacleEvent.new(type as ObstacleType)
	_handle_obstacle_event(event)

#
# Removing the artefact and raising the central cell is managed as an event,
# rather than by calling _remove_artefact() directly, in case the center row or
# column is sliding (the central cell can't slide and rise at the same time).
#
func _on_center_timer_timeout():
	var event = ObstacleEvent.new(ObstacleType.REMOVE_ARTEFACT)
	event.cell = _center_cell
	_handle_obstacle_event(event)

#
# Removes the artefact above the central cell, raises the central cell after a
# pause, then creates the exit door after another pause.
#
func _remove_artefact():
	await _center_cell.remove_artefact()
	var pause_length = 2 * Globals.difficulty
	await get_tree().create_timer(pause_length).timeout
	await _center_cell.raise()
	await get_tree().create_timer(pause_length).timeout
	_center_cell.add_door()

##
## Removes a one-way obstacle immediately, rather than waiting for the duration
## of the obstacle to lapse.
##
func cancel_one_way(cell: Cell):
	var event = ObstacleEvent.new(ObstacleType.CELL_ONE_WAY)
	event.cell = cell
	event.is_undo = true
	_handle_obstacle_event(event)

##
## Removes a teleport obstacle (both cells) immediately, rather than waiting for
## the duration of the obstacle to lapse.
##
func cancel_teleport(cell: Cell):
	var type = ObstacleType.CELL_TELEPORT1 + (cell.get_teleport_type() - 1)
	var event = ObstacleEvent.new(type as ObstacleType)
	event.cell = cell
	event.cell2 = cell.get_teleport_partner()
	event.is_undo = true
	_handle_obstacle_event(event)
