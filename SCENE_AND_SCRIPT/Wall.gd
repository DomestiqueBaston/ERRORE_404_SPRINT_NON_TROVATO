class_name Wall extends Node2D

## Signal emitted when the wall has disappeared or been removed.
signal gone

## Cell the wall is attached to.
var cell: Cell

## The delay in milliseconds before a point is made visible
const delay_msec: int = 100

## The delay in seconds before a point is made visible
const delay: float = delay_msec / 1000.0

## How long in milliseconds a point is displayed after delay.
var duration_msec: int = \
	3000 + roundi(7000 * (Globals.difficulty + (2 * Globals.map_size + 1) - 10) / 16.0)

@onready var _mesh_instance: MeshInstance2D = $Mesh
@onready var _animation: AnimationPlayer = $Animation
@onready var _collider_shape: CollisionShape2D = $Collider/Shape
@onready var _hum: AudioStreamPlayer2D = $Sounds/Wall_Hum

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

##
## Adds a point to the wall. The wall is not visible until at least two points
## have been added. Points are made visible after a slight delay (see the delay
## constant), and become invisible again after a certain amount of time has
## elapsed (see duration_msec).
##
## It is assumed that the wall is a straight line, i.e. that the points added
## are all colinear, which greatly simplifies display and collision detection.
## So if the runner changes direction, start a new wall.
##
func add_point(pos: Vector2):
	_points.push_back(pos)
	_times.push_back(Time.get_ticks_msec())
	set_physics_process(true)

##
## Returns the last point that was added to this wall. Returns null if no
## points have been added, or if they have all since disappeared.
##
func get_last_point():
	return _points.back() if _points else null

func _update_mesh():
	var now = Time.get_ticks_msec()

	# discard the oldest points

	var time_limit = now - delay_msec - duration_msec
	while not _times.is_empty() and _times[0] < time_limit:
		_points.pop_front()
		_times.pop_front()

	# if no new points have been added in a while, assume we're done

	if _points.is_empty():
		remove()
		return

	# count the points that are old enough to be visible

	var count = 0
	time_limit = now - delay_msec

	while count < _times.size():
		if _times[count] >= time_limit:
			break
		count += 1

	if count <= 1:
		return

	# make a single parallelogram from the first visible point and the last (it
	# is assumed that the points are all colinear)

	const dy = Vector2(0, -80)
	var p1 = _points[0]
	var p2 = _points[count-1]
	var xy = PackedVector2Array()
	var uv = PackedVector2Array()

	xy.resize(4)
	uv.resize(4)

	xy[0] = p1
	xy[1] = p1 + dy
	xy[2] = p2
	xy[3] = p2 + dy

	uv[0] = Vector2(0, 1)
	uv[1] = Vector2(0, 0)
	uv[2] = Vector2(1, 1)
	uv[3] = Vector2(1, 0)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = xy
	arrays[Mesh.ARRAY_TEX_UV] = uv

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	_mesh_instance.mesh = mesh

	# the collider is a single segment from the first visible point to the last

	var segment = SegmentShape2D.new()
	segment.a = p1
	segment.b = p2
	_collider_shape.shape = segment

	#const thickness = 20
	#var rect = RectangleShape2D.new()
	#var vec = p2 - p1
	#var dist = vec.length()
	#rect.size = Vector2(dist + thickness, thickness)
	#_collider_shape.rotation = vec.angle()
	#_collider_shape.position = (p1 + p2) * 0.5
	#_collider_shape.shape = rect

	# hum for as long as the wall is visible

	if not _hum.playing:
		_hum.play()

##
## Disappears the wall if any points have been added to it in the given lapse of
## time. First, any points that have been added to the wall but not yet made
## visible are eliminated. Then, if the wall still contains one or more points
## added recently, disappear() is called. If no points have been added in that
## time, the wall is unaffected.
##
func backup(msec: int = delay_msec):
	if _points.is_empty():
		return

	# eliminate any points that have not appeared yet

	var now = Time.get_ticks_msec()
	var time_limit = now - delay_msec
	var new_size = _times.size()
	while new_size > 0 and _times[new_size - 1] >= time_limit:
		new_size -= 1

	if new_size == 0:
		remove()
		return

	_points.resize(new_size)
	_times.resize(new_size)

	# if there are any points left that are younger than msec, make the whole
	# wall disappear

	if _times.back() >= now - msec:
		disappear()

##
## Resets the wall and emits a gone signal.
##
func remove():
	_hum.stop()
	_mesh_instance.mesh = null
	_points.clear()
	_times.clear()
	set_physics_process(false)
	gone.emit()

##
## Animation that can be played when the wall appears: it flashes off an on,
## accompanied by a sound effect.
##
func appear():
	_animation.play(&"Appearing")

##
## Animation that can be played to make the wall disappear: it flashes on and
## off, accompanied by a sound effect. The wall is removed, emitting a gone
## signal, when the animation finishes.
##
func disappear():
	_animation.play(&"Disappearing")
	await _animation.animation_finished
	remove()
