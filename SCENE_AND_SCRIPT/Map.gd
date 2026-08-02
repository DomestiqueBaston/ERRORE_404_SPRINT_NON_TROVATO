@tool
class_name Map extends Node2D

@export_range(4, 10) var cell_count: int = 4:
	set(count):
		if cell_count != count:
			cell_count = count
			build()

var _cell_scene := preload("res://SCENE_AND_SCRIPT/Cell.tscn")

const _cell_offset_x = 236.0
const _cell_offset_y = 118.0
const _southeast = 0.5 * Vector2(_cell_offset_x, _cell_offset_y)
const _northeast = 0.5 * Vector2(_cell_offset_x, -_cell_offset_y)

var _cells = {}

enum EdgeType {
	NW, NE, SW, SE
}

func _ready():
	build()
	#$mycam.make_current()

func _input(event: InputEvent):
	if event is InputEventKey and event.is_pressed():
		if event.keycode == Key.KEY_1:
			var uv = Vector2i(2, 1)
			_cells[uv].sink(5)

func build():
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
			var candidates = deco_options.duplicate()
			if x > 0 and x-1 != middle_cell:
				candidates.erase(decos[x-1][y])
			if y > 0 and y-1 != middle_cell:
				candidates.erase(decos[x][y-1])
			decos[x].append(candidates.pick_random())
			if x == middle_cell and y == middle_cell:
				continue
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
# UV (0,0) is the origin of the map.
#
func _get_cell_pos(uv: Vector2i) -> Vector2:
	return uv.x * _southeast + uv.y * _northeast
