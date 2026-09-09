class_name Wall extends Node2D

## Signal emitted when the wall has disappeared or been removed.
signal gone

## Cell the wall is attached to.
var cell: Cell

## The delay in milliseconds before a point is made visible
const delay_msec: int = 50

## The delay in seconds before a point is made visible
const delay: float = delay_msec / 1000.0

## How long in milliseconds a point is displayed after delay.
var duration_msec: int = \
	3000 + roundi(7000 * (Globals.difficulty + (2 * Globals.map_size + 1) - 10) / 16.0)

@onready var _mesh_instance: MeshInstance2D = $Mesh
@onready var _animation: AnimationPlayer = $Animation
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

	while not _times.is_empty() and _times[0] + delay_msec + duration_msec < now:
		_points.pop_front()
		_times.pop_front()

	# if no new points have been added in a while, assume we're done

	if _points.is_empty():
		remove()
		return

	# count the points that are old enough to be visible

	var count = 0

	while count < _times.size():
		if _times[count] + delay_msec >= now:
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

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)
	_mesh_instance.mesh = mesh

	# hum for as long as the wall is visible

	if not _hum.playing:
		_hum.play()

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
