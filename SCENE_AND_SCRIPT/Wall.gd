class_name Wall extends MeshInstance2D

## Signal emitted when the wall has disappeared.
signal gone

# Cell the wall is attached to
var cell: Cell

# delay in msec before a point is made visible
const _delay: int = 100

# how long in msec a point is displayed
var _duration: int = \
	3000 + roundi(7000 * (Globals.difficulty + (2 * Globals.map_size + 1) - 10) / 16.0)

# points constituting the wall
var _points: Array[Vector2]

# time in msec when each point was added
var _times: Array[int]

func _ready():
	# same rendering layer as cells
	z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	# don't start processing until there are points to be processed
	set_physics_process(false)

func _physics_process(_delta: float):
	_update_mesh()

func add_point(pos: Vector2):
	_points.push_back(pos)
	_times.push_back(Time.get_ticks_msec())
	set_physics_process(true)

func get_last_point():
	return _points.back() if _points else null

func _update_mesh():
	var now = Time.get_ticks_msec()

	# discard the oldest points

	while not _times.is_empty() and _times[0] + _delay + _duration <= now:
		_points.pop_front()
		_times.pop_front()

	# if no new points have been added in a while, assume we're done

	if _points.is_empty():
		remove()
		return

	# count the points that are old enough to be visible

	var count = 0
	while count < _times.size():
		if _times[count] + _delay > now:
			break
		count += 1

	if count <= 1:
		return

	# convert the visible points to a mesh

	var xy = PackedVector2Array()
	var uv = PackedVector2Array()
	xy.resize(2 * count)
	uv.resize(2 * count)
	var div = count as float

	for i in count:
		xy[2*i] = _points[i]
		xy[2*i+1] = _points[i] + Vector2(0, -80)
		var u = i / div
		uv[2*i] = Vector2(u, 1)
		uv[2*i+1] = Vector2(u, 0)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = xy
	arrays[Mesh.ARRAY_TEX_UV] = uv

	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)

func remove():
	mesh = null
	_points.clear()
	_times.clear()
	set_physics_process(false)
	gone.emit()
