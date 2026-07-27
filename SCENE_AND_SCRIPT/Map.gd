@tool
class_name Map extends Node2D

@export_range(4, 10) var cell_count: int = 4:
	set(count):
		if cell_count != count:
			cell_count = count
			build()

var _cell_scene := preload("res://SCENE_AND_SCRIPT/Cell.tscn")
var _cell_offset := Vector2(236, 118)

enum EdgeType {
	NW, NE, SW, SE
}

func _ready():
	build()

func build():
	var parent: Node2D = self

	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

	var cell: Cell

	# center

	cell = _cell_scene.instantiate()
	cell.decoration = Cell.Decoration.CENTER
	parent.add_child(cell)

	# corners

	cell = _cell_scene.instantiate()
	cell.decoration = Cell.Decoration.N
	cell.position.y = cell_count * -_cell_offset.y
	parent.add_child(cell)

	cell = _cell_scene.instantiate()
	cell.decoration = Cell.Decoration.S
	cell.position.y = cell_count * _cell_offset.y
	parent.add_child(cell)

	cell = _cell_scene.instantiate()
	cell.decoration = Cell.Decoration.W
	cell.position.x = cell_count * -_cell_offset.x
	parent.add_child(cell)

	cell = _cell_scene.instantiate()
	cell.decoration = Cell.Decoration.E
	cell.position.x = cell_count * _cell_offset.x
	parent.add_child(cell)

	# edges

	_build_edge(parent, EdgeType.NW)
	_build_edge(parent, EdgeType.NE)
	_build_edge(parent, EdgeType.SW)
	_build_edge(parent, EdgeType.SE)

	# interior

	var interior_cell_count = 2 * cell_count - 1
	var middle_cell = cell_count - 1
	var southeast = 0.5 * Vector2(_cell_offset.x,  _cell_offset.y)
	var northeast = 0.5 * Vector2(_cell_offset.x, -_cell_offset.y)
	var basepos = Vector2((cell_count - 1) * -_cell_offset.x, 0)
	var deco_options = [0, 1, 2, 3, 4, 5, 6, 7]
	var deco = []

	for x in interior_cell_count:
		var pos0 = basepos + x * southeast
		deco.append([])
		for y in interior_cell_count:
			var candidates = deco_options.duplicate()
			if x > 0 and x-1 != middle_cell:
				candidates.erase(deco[x-1][y])
			if y > 0 and y-1 != middle_cell:
				candidates.erase(deco[x][y-1])
			deco[x].append(candidates.pick_random())
			if x == middle_cell and y == middle_cell:
				continue
			cell = _cell_scene.instantiate()
			cell.decoration = (Cell.Decoration.OTHER1 + deco[x][y]) as Cell.Decoration
			cell.position = pos0 + y * northeast
			parent.add_child(cell)

func _build_edge(parent: Node2D, edge: EdgeType):
	var pos: Vector2
	var delta: Vector2
	var deco1: Cell.Decoration

	match edge:
		EdgeType.NW:
			pos = Vector2(cell_count * -_cell_offset.x, 0)
			delta = 0.5 * Vector2(_cell_offset.x, -_cell_offset.y)
			deco1 = Cell.Decoration.NW1
		EdgeType.NE:
			pos = Vector2(0, cell_count * -_cell_offset.y)
			delta = 0.5 * _cell_offset
			deco1 = Cell.Decoration.NE1
		EdgeType.SW:
			pos = Vector2(0, cell_count * _cell_offset.y)
			delta = 0.5 * -_cell_offset
			deco1 = Cell.Decoration.SW1
		EdgeType.SE:
			pos = Vector2(cell_count * _cell_offset.x, 0)
			delta = 0.5 * Vector2(-_cell_offset.x, _cell_offset.y)
			deco1 = Cell.Decoration.SE1

	var edge_cell_count = 2 * cell_count - 1
	var deco_offset = randi() % 3

	for i in edge_cell_count:
		var cell: Cell = _cell_scene.instantiate()
		cell.decoration = (deco1 + deco_offset) as Cell.Decoration
		cell.position = pos + delta * (i+1)
		parent.add_child(cell)
		deco_offset = (deco_offset + randi_range(1, 2)) % 3
