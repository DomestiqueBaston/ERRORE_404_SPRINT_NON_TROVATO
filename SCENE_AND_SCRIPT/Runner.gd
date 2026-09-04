extends Node2D

## La Vision_Area n'est pas gérée par ce script,
## c'est juste de la démo...

@onready var character: Node2D = $Character
@onready var sprite: Node2D = $Character/Papa_Sprite
@onready var animation_player: AnimationPlayer = $Animation_Runner
@onready var disappear_player: AnimationPlayer = $Animation_Disappearing_Death
@onready var collider: Area2D = $Character/Papa_Sprite/Runner_Sprite/Collider_Area
@onready var wall: MeshInstance2D = $Wall

@onready var _footstep1 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_01
@onready var _footstep2 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_02
@onready var _footstep3 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_03

@export var move_speed: float = 395.0
@export var jump_speed: float = 385.0
@export var slide_speed: float = 375.0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO

# États
var is_jumping: bool = false
var is_sliding: bool = false
var is_dead: bool = false
var is_falling: bool = false
var is_teleporting: bool = false
var is_one_way: bool = false
var is_exiting: bool = false

# Directions figées
var jump_direction: Vector2 = Vector2.ZERO
var slide_direction: Vector2 = Vector2.ZERO

const _rotation: float = deg_to_rad(18.4)
var _northwest: Vector2 = Vector2(-1, -1).rotated(-_rotation).normalized()
var _northeast: Vector2 = Vector2(1, -1).rotated(_rotation).normalized()
var _southwest: Vector2 = Vector2(-1, 1).rotated(_rotation).normalized()
var _southeast: Vector2 = Vector2(1, 1).rotated(-_rotation).normalized()

var _map: Map
var _physics_ready: bool = false
var _start_cell: Cell
var _curr_cell: Cell
var _curr_cell_pos: Vector2
var _history: PackedVector2Array

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	disappear_player.animation_finished.connect(_on_disappear_finished)
	z_index = roundi(global_position.y)
	wall.z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	_init_wall()

func set_map(map: Map, start_cell: Cell = null):
	_map = map
	if start_cell:
		_start_cell = start_cell
	else:
		_start_cell = map.get_center_cell()

func _physics_process(delta: float) -> void:

	# skip first frame to allow physics server to find initial collisions
	if not _physics_ready:
		_physics_ready = true
		return

	# check for obstacles, sliding cells, etc.
	if _check_location():
		# back up if the runner hit an obstacle and died
		position += direction * _get_current_speed() * -delta
		z_index = roundi(global_position.y)

	# États bloquants : plus rien à faire
	if is_dead or is_falling:
		return

	# check user input, if he is in control
	if not (is_jumping or is_sliding or is_one_way):
		var input_direction := Vector2.ZERO

		if Input.is_action_just_pressed("ui_a_button") :
			_play_jump_animation()
		elif Input.is_action_just_pressed("ui_b_button"):
			_play_slide_animation()
		elif Globals.use_diagonals_for_movement:
			if Input.is_action_pressed("ui_left_button"):
				if Input.is_action_pressed("ui_down_button"):
					input_direction = _southwest
				elif Input.is_action_pressed("ui_up_button"):
					input_direction = _northwest
			elif Input.is_action_pressed("ui_right_button"):
				if Input.is_action_pressed("ui_down_button"):
					input_direction = _southeast
				elif Input.is_action_pressed("ui_up_button"):
					input_direction = _northeast
		else:
			if Input.is_action_pressed("ui_left_button"):
				input_direction = _northwest
			elif Input.is_action_pressed("ui_up_button"):
				input_direction = _northeast
			elif Input.is_action_pressed("ui_right_button"):
				input_direction = _southeast
			elif Input.is_action_pressed("ui_down_button"):
				input_direction = _southwest

		if input_direction and is_valid_direction(input_direction):
			last_direction = input_direction

	# === Direction actuelle ===
	if is_jumping:
		direction = jump_direction
	elif is_sliding:
		direction = slide_direction
	else:
		direction = last_direction

	# === Mouvement ===
	if direction:
		position += direction * _get_current_speed() * delta
		z_index = roundi(global_position.y)
		_add_to_wall()

	# keep camera aimed at runner
	$Character/Cam.update_aim_point(global_position)

	# === Animations normales (seulement si pas en action spéciale) ===
	if not is_jumping and not is_sliding:
		if direction == Vector2.ZERO:
			if last_direction == Vector2.ZERO:
				animation_player.play("Intro")
			else:
				if last_direction.y < 0:
					animation_player.play("Start_000")
					sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
				else:
					animation_player.play("Start_180")
					sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0
		else:
			if direction.y < 0:
				animation_player.play("Run_000")
				sprite.scale.x = 1.0 if direction.x < 0 else -1.0
			else:
				animation_player.play("Run_180")
				sprite.scale.x = -1.0 if direction.x < 0 else 1.0

func _get_current_speed() -> float:
	if is_jumping and animation_player.current_animation.begins_with("Jump_"):
		var progress = (animation_player.current_animation_position /
						animation_player.current_animation_length)
		return lerp(move_speed, jump_speed, progress)
	elif is_sliding and animation_player.current_animation.begins_with("Sliding_"):
		var progress = (animation_player.current_animation_position /
						animation_player.current_animation_length)
		return lerp(move_speed, slide_speed, progress)
	else:
		return move_speed

func _play_jump_animation() -> void:
	if last_direction == Vector2.ZERO or is_dead or is_falling: return
	is_jumping = true
	jump_direction = last_direction
	if last_direction.y < 0:
		animation_player.play("Jump_000")
		sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
	else:
		animation_player.play("Jump_180")
		sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0

func _play_slide_animation() -> void:
	if last_direction == Vector2.ZERO or is_dead or is_falling: return
	is_sliding = true
	slide_direction = last_direction
	if last_direction.y < 0:
		animation_player.play("Sliding_000")
		sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
	else:
		animation_player.play("Sliding_180")
		sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0


# ── MORT ──
func die(fast: bool) -> void:
	if is_dead: return
	is_dead = true
	
	if fast:
		disappear_player.play("Disappearing")
	elif last_direction == Vector2.ZERO:
		animation_player.play("Death_180")
	else:
		if last_direction.y < 0:
			animation_player.play("Death_000")
			sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
		else:
			animation_player.play("Death_180")
			sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0


# ── CHUTE (nouvelle fonction) ──
func start_falling() -> void:
	if is_falling or is_dead: return
	is_falling = true
	
	# no more movement
	set_physics_process(false)

	z_index = RenderingServer.CANVAS_ITEM_Z_MIN
	character.z_index = 0

	# Animation de chute avec la bonne orientation
	if last_direction == Vector2.ZERO:
		animation_player.play("Falling_180")
	else:
		if last_direction.y < 0:
			animation_player.play("Falling_000")
			sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
		else:
			animation_player.play("Falling_180")
			sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("Jump_"):
		is_jumping = false
		jump_direction = Vector2.ZERO
	elif anim_name.begins_with("Sliding_"):
		is_sliding = false
		slide_direction = Vector2.ZERO
	elif anim_name.begins_with("Death_"):
		disappear_player.play("Disappearing")

	# Rien à faire si mort ou en chute (on reste sur l’animation)
	if is_dead or is_falling:
		return

	if direction != Vector2.ZERO:
		if direction.y < 0:
			animation_player.play("Run_000")
			sprite.scale.x = 1.0 if direction.x < 0 else -1.0
		else:
			animation_player.play("Run_180")
			sprite.scale.x = -1.0 if direction.x < 0 else 1.0
	else:
		if last_direction == Vector2.ZERO:
			animation_player.play("Intro")
		elif last_direction.y < 0:
			animation_player.play("Start_000")
			sprite.scale.x = 1.0 if last_direction.x < 0 else -1.0
		else:
			animation_player.play("Start_180")
			sprite.scale.x = -1.0 if last_direction.x < 0 else 1.0

func _on_disappear_finished(_anim_name: String):
	set_physics_process(false)

func is_valid_direction(new_direction: Vector2) -> bool:
	if last_direction == Vector2.ZERO:
		return true
	return not is_zero_approx(last_direction.dot(new_direction) + 1.0)

#
# Checks whether the runner's location (current cell) has changed, and if he
# has encountered an obstacle, or a teleport, or fallen off the map, etc. On
# return, he may be dead or falling (it is assumed that he is not, at the time
# when the function is called).
#
# Returns true if the runner died after running into something, in which case
# he should bounce back in the direction he was moving.
#
func _check_location() -> bool:
	if _map == null:
		return false

	# find the cell underfoot

	var next_cell: Cell = _map.get_cell_in_area(collider)

	# Turn one-way off after leaving the one-way cell. Normally one-way is
	# turned off by _check_one_way() when the runner is no longer in contact
	# with the one-way sign's collider. But if the runner steps directly from
	# that collider to a neighboring cell, or to a space where there is no cell,
	# _check_one_way() will not be called.

	if is_one_way and next_cell != _curr_cell:
		is_one_way = false

	# update the current cell accordingly and check for obstacles

	var hit_door = false

	if next_cell and next_cell.is_center():
		if not is_dead and not is_exiting:
			if next_cell.get_artefact():
				die(false)
			elif next_cell.get_door():
				match next_cell.get_door().get_zone_at(collider):
					Door.Zone.FRAME:
						die(false)
						hit_door = true
					Door.Zone.PASSAGE:
						print("we're out!")
						character.z_index = Door.Depth.MIDDLE
						is_exiting = true
					Door.Zone.BACK:
						character.z_index = Door.Depth.BACK
					Door.Zone.MIDDLE:
						character.z_index = Door.Depth.MIDDLE
					Door.Zone.FRONT:
						character.z_index = Door.Depth.FRONT
			elif next_cell.get_state() == Cell.State.LOWERED:
				if not is_jumping:
					start_falling()
	else:
		character.z_index = 0
		is_exiting = false
		if next_cell:
			match next_cell.get_state():
				Cell.State.LOWERED, Cell.State.HIDDEN:
					if not is_jumping:
						start_falling()
				Cell.State.TELEPORT:
					_check_teleport(next_cell)
				Cell.State.ONE_WAY:
					_check_one_way(next_cell)
				Cell.State.PYLON:
					_check_pylon(next_cell)
		else:
			if not is_jumping:
				start_falling()

	# Did the runner run into something, in which case he has to bounce back?
	# The check whether the runner has just moved to a different cell is to
	# distinguish between cases where he runs into a cell containing a pylon or
	# an artefact (bounce back), and cases where a pylon falls on him in his
	# current cell (don't bounce, just die instantly). Running into the frame of
	# the door in the central cell is different: the door's collider is smaller
	# than the cell's, so it is likely the runner will hit it after entering the
	# cell.

	var backup = is_dead and (_curr_cell != next_cell or hit_door)

	# if the runner hasn't moved to a different cell and the cell is moving,
	# move the runner with it

	if _curr_cell and _curr_cell == next_cell and not (is_falling or is_jumping):
		position += _curr_cell.global_position - _curr_cell_pos
		z_index = roundi(global_position.y)

	# note the current cell and position for next time

	_curr_cell = next_cell
	if _curr_cell:
		_curr_cell_pos = _curr_cell.global_position

	return backup

func _check_teleport(cell: Cell):
	var destination = cell.get_teleport_partner()
	if is_teleporting or destination == null:
		return
	is_teleporting = true
	$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Teleport.play()
	var anim: AnimationPlayer = $Animation_Bonus_Malus
	anim.play("Bonus_Malus")
	await anim.animation_finished
	_curr_cell = destination
	_curr_cell_pos = destination.global_position
	global_position = _curr_cell_pos
	z_index = roundi(global_position.y)
	is_teleporting = false
	anim.play("Bonus_Malus")
	if _map:
		await anim.animation_finished
		_map.cancel_teleport(destination)

func _check_one_way(cell: Cell):

	# no overlap with one-way collider: turn one-way off, if it is on, and do
	# nothing

	if not collider.overlaps_area(cell.get_one_way_collider()):
		is_one_way = false
		return

	# one-way is already on: do nothing

	if is_one_way:
		return

	# runner just ran into the one-way sign: choose his new direction

	var new_direction: Vector2
	match cell.get_one_way_direction():
		Globals.Axis.NW:
			new_direction = _northwest
		Globals.Axis.NE:
			new_direction = _northeast
		Globals.Axis.SW:
			new_direction = _southwest
		Globals.Axis.SE:
			new_direction = _southeast

	# if the runner is going the opposite direction, kill him

	if is_equal_approx(direction.dot(new_direction), -1.0):
		die(false)
		return

	# play the Bonus_Malus animation before actually changing the runner's
	# direction, then again, and finally remove the one-way obstacle

	var anim: AnimationPlayer = $Animation_Bonus_Malus
	anim.play("Bonus_Malus")
	await anim.animation_finished
	last_direction = new_direction
	if is_jumping:
		jump_direction = new_direction
	elif is_sliding:
		slide_direction = new_direction
	is_one_way = true
	anim.play("Bonus_Malus")
	if _map:
		_map.cancel_one_way(cell)

func _check_pylon(cell: Cell):
	# if the runner was already on the cell when the pylon is lowered or
	# dropped, he just disappears: see die()
	match cell.get_pylon().get_state():
		Pylon.State.LOWERED:
			if not is_sliding:
				die(cell == _curr_cell)
		Pylon.State.DROPPED:
			die(cell == _curr_cell)

#
# Methods called by run cycle animation.
#
func play_foot_step_01():
	_footstep1.play()

func play_foot_step_02():
	_footstep2.play()

func play_foot_step_03():
	_footstep3.play()

func _init_wall():
	_history.push_back(global_position)

func _add_to_wall():
	if _history.size() == 120:
		_history.remove_at(0)
	_history.push_back(global_position)

	var xy = PackedVector2Array()
	var uv = PackedVector2Array()
	xy.resize(2 * _history.size())
	uv.resize(2 * _history.size())

	var div = _history.size() as float
	for i in _history.size():
		xy[2*i] = _history[i]
		xy[2*i+1] = _history[i] + Vector2(0, -80)
		var u = i / div
		uv[2*i] = Vector2(u, 1)
		uv[2*i+1] = Vector2(u, 0)

	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = xy
	arrays[Mesh.ARRAY_TEX_UV] = uv

	var mesh: ArrayMesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_STRIP, arrays)

	wall.mesh = mesh
