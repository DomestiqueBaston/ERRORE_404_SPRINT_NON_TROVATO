class_name Wall extends CellAttachment

## Signal emitted when the wall has disappeared or been removed.
signal gone

## The delay in seconds before a point is made visible.
const delay: float = 0.1

## How long in seconds a point is displayed after delay.
var duration: float = \
	3 + 7 * (Globals.difficulty + (2 * Globals.map_size + 1) - 10) / 16.0

@onready var _mesh_instance: MeshInstance2D = $Mesh
@onready var _animation: AnimationPlayer = $Animation
@onready var _collider_shape: CollisionShape2D = $Collider/Shape
@onready var _hum: AudioStreamPlayer2D = $Sounds/Wall_Hum

# points constituting the wall
var _points: PackedVector2Array

# lifetime in seconds: negative before display, positive afterward
var _times: PackedFloat64Array

# how many times add_point() has been called
var _points_added: int = 0

func _ready():
	# don't start processing until there are points to be processed
	set_physics_process(false)

func _physics_process(delta: float):
	_update_mesh(delta)

##
## Adds a point to the wall. The wall is not visible until at least two points
## have been added. Points are made visible after a slight delay (see the delay
## constant), and become invisible again after a certain amount of time has
## elapsed (see duration).
##
## It is assumed that the wall is a straight line, i.e. that the points added
## are all colinear, which greatly simplifies display and collision detection.
## So if the runner changes direction, start a new wall.
##
func add_point(global_pos: Vector2):
	_points.push_back(cell.to_local(global_pos) if cell else global_pos)
	_times.push_back(-delay)
	_points_added += 1

	match _points_added:
		# Special case when only one point is ever added: after a short time,
		# assume that no others are going to follow.
		1:
			await get_tree().create_timer(1).timeout
			if _points_added == 1:
				remove()
		# Once a second point has been added, start updating the mesh and
		# collider; updates will be stopped when no points are left.
		2:
			set_physics_process(true)

##
## Returns the last point that was added to this wall. Returns null if no
## points have been added, or if they have all since disappeared.
##
func get_last_point():
	if _points:
		return cell.to_global(_points[-1]) if cell else _points[-1]
	else:
		return null

func _update_mesh(delta: float):

	# update times for all points

	for i in _times.size():
		_times[i] += delta

	# discard the oldest points

	while not _times.is_empty() and _times[0] > duration:
		_points.remove_at(0)
		_times.remove_at(0)

	# if no points are left, assume no more are going to follow and we're done

	if _points.is_empty():
		remove()
		return

	# count the points that are old enough to be visible

	var count = 0

	while count < _times.size():
		if _times[count] < 0.0:
			break
		count += 1

	if count <= 1:
		_mesh_instance.mesh = null
		_collider_shape.shape = null
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
func backup(sec: float = delay):
	if _points.is_empty():
		return

	# eliminate any points that have not appeared yet

	var new_size = _times.size()
	while new_size > 0 and _times[new_size - 1] < 0.0:
		new_size -= 1

	if new_size == 0:
		remove()
		return

	_points.resize(new_size)
	_times.resize(new_size)

	# if there are any points left that are younger than sec, make the whole
	# wall disappear

	if _times[-1] < sec:
		disappear()

##
## Resets the wall and emits a gone signal.
##
func remove():
	_hum.stop()
	_mesh_instance.mesh = null
	_collider_shape.shape = null
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

##
## Given the collider from a wall, returns the Wall itself. Returns null if the
## collider does not belong to a wall.
##
static func get_wall_from_collider(collider: Area2D) -> Wall:
	var wall = collider.get_node_or_null("..")
	return wall if wall is Wall else null
