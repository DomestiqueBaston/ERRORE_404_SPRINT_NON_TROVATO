##
## CellAttachment is intended as a superclass for any Node2D that appears on
## top of a Cell. It automatically sets the node's Z-index from the Y coordinate
## of the corresponding cell's global position. That way all cells are drawn
## first, using Y-sort (because cells are drawn in their own layer), then all
## nodes on top of cells (pylons, doors, etc.) are drawn afterward, but in the
## same order as cells.
##
class_name CellAttachment extends Node2D

## The Cell this node sits on top of.
var cell: Cell: set = set_cell

#
# If z_as_relative is set in _ready(), and a superclass also defines a _ready()
# function, then z_as_relative is not set correctly, for some reason.
#
func _init():
	z_as_relative = false

func _ready():
	if cell:
		on_cell_pos_changed()

func set_cell(c: Cell):
	if cell != c:
		if cell:
			cell.position_changed.disconnect(on_cell_pos_changed)
		cell = c
		if cell:
			on_cell_pos_changed()
			cell.position_changed.connect(on_cell_pos_changed)

func on_cell_pos_changed():
	z_index = roundi(cell.global_position.y)
