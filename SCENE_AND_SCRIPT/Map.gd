@tool
class_name Map extends Node2D

@export_range(4, 10) var cell_count: int = 4:
	set(count):
		if cell_count != count:
			cell_count = count
			_build_map()

@export var slide_speed: float = 9

var _cell_scene := preload("res://SCENE_AND_SCRIPT/Cell.tscn")

const _cell_offset_x = 236.0
const _cell_offset_y = 118.0
const _southeast = 0.5 * Vector2(_cell_offset_x, _cell_offset_y)
const _northeast = 0.5 * Vector2(_cell_offset_x, -_cell_offset_y)

var _cells: Dictionary[Vector2i, Cell]

enum EdgeType {
	NW, NE, SW, SE
}

func _ready():
	_build_map()
	set_process_input(not Engine.is_editor_hint())

func _input(event: InputEvent):
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			Key.KEY_1:
				_lower_cell(Vector2i(2, 1))
			Key.KEY_2:
				_raise_cell(Vector2i(2, 1))
			Key.KEY_3:
				_slide_column(2, 2)
			Key.KEY_4:
				_slide_column(2, -2)
			Key.KEY_5:
				_hide_cell(Vector2i(2, 1))
			Key.KEY_6:
				_show_cell(Vector2i(2, 1))
			Key.KEY_7:
				_start_cell_one_way(Vector2i(2, 1))
			Key.KEY_8:
				_stop_cell_one_way(Vector2i(2, 1))

func _build_map():
	var parent: Node2D = self

	for cell in _cells.values():
		parent.remove_child(cell)
		cell.queue_free()

	_cells.clear()

	# center

	_add_cell(parent, Vector2i(0, 0), Cell.Decoration.CENTER)

	# corners

	_add_cell(parent, Vector2i(-cell_count, cell_count), Cell.Decoration.N)
	_add_cell(parent, Vector2i(cell_count, -cell_count), Cell.Decoration.S)
	_add_cell(parent, Vector2i(-cell_count, -cell_count), Cell.Decoration.W)
	_add_cell(parent, Vector2i(cell_count, cell_count), Cell.Decoration.E)

	# edges

	_build_edge(parent, EdgeType.NW)
	_build_edge(parent, EdgeType.NE)
	_build_edge(parent, EdgeType.SW)
	_build_edge(parent, EdgeType.SE)

	# interior

	var interior_cell_count = 2 * cell_count - 1
	var middle_cell = cell_count - 1
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
				var uv = Vector2i(-cell_count + x+1, -cell_count + y+1)
				var deco = Cell.Decoration.OTHER1 + decos[x][y]
				_add_cell(parent, uv, deco as Cell.Decoration)

func _build_edge(parent: Node2D, edge: EdgeType):
	var uv0: Vector2i
	var uvd: Vector2i
	var deco1: Cell.Decoration

	match edge:
		EdgeType.NW:
			uv0 = Vector2i(-cell_count, -cell_count + 1)
			uvd = Vector2i(0, 1)
			deco1 = Cell.Decoration.NW1
		EdgeType.NE:
			uv0 = Vector2i(-cell_count + 1, cell_count)
			uvd = Vector2i(1, 0)
			deco1 = Cell.Decoration.NE1
		EdgeType.SW:
			uv0 = Vector2i(cell_count - 1, -cell_count)
			uvd = Vector2i(-1, 0)
			deco1 = Cell.Decoration.SW1
		EdgeType.SE:
			uv0 = Vector2i(cell_count, cell_count - 1)
			uvd = Vector2i(0, -1)
			deco1 = Cell.Decoration.SE1

	var edge_cell_count = 2 * cell_count - 1
	var deco_offset = randi() % 3

	for i in edge_cell_count:
		var uv: Vector2i = uv0 + i * uvd
		var deco = deco1 + deco_offset
		deco_offset = (deco_offset + randi_range(1, 2)) % 3
		_add_cell(parent, uv, deco as Cell.Decoration)

#
# Creates a new cell at the given position and with the given decoration.
#
func _add_cell(parent: Node2D, uv: Vector2i, deco: Cell.Decoration):
	var cell: Cell = _cell_scene.instantiate()
	cell.position = _get_cell_pos(uv)
	cell.decoration = deco
	parent.add_child(cell)
	_cells[uv] = cell

#
# Returns the position in XY coordinates of the cell at the given UV index,
# where U corresponds to the NW-SE axis, V corresponds to the SW-NE axis, and
# UV (0,0) is the origin of the map. The given cell may or may not actually
# exist.
#
static func _get_cell_pos(uv: Vector2i) -> Vector2:
	return uv.x * _southeast + uv.y * _northeast

func _lower_cell(uv: Vector2i):
	Sounds.play_cell_up_down()
	await get_tree().create_timer(1).timeout
	await _cells[uv].lower()
	Sounds.stop_cell_up_down()

func _raise_cell(uv: Vector2i):
	Sounds.play_cell_up_down()
	await get_tree().create_timer(1).timeout
	await _cells[uv].raise()
	Sounds.stop_cell_up_down()

func _hide_cell(uv: Vector2i):
	Sounds.play_cell_disappearing()
	await get_tree().create_timer(1).timeout
	await _cells[uv].disappear()

func _show_cell(uv: Vector2i):
	Sounds.play_cell_disappearing()
	await get_tree().create_timer(1).timeout
	await _cells[uv].reappear()

func _start_cell_one_way(uv: Vector2i):
	_cells[uv].start_one_way()

func _stop_cell_one_way(uv: Vector2i):
	_cells[uv].stop_one_way()

#
# Slides the given column (u) the given number of cells to the right (if
# distance is positive) or to the left (if negative).
#
func _slide_column(u: int, distance: int):
	_slide(&"x", u, distance)

#
# Slides the given row (v) the given number of cells upward (if distance is
# positive) or downward (if negative).
#
func _slide_row(v: int, distance: int):
	_slide(&"y", v, distance)

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

	var pause: float = _cells.values().front().get_sliding_animation_length()
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

	Sounds.stop_cell_slide()
