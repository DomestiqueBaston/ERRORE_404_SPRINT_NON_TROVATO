extends Node2D

## La Vision_Area n'est pas gérée par ce script,
## c'est juste de la démo...

@export var move_speed: float = 395.0
@export var jump_speed: float = 375.0
@export var slide_speed: float = 375.0

@onready var _sprite_node: Node2D = $Character/Papa_Sprite
@onready var _sprite: Sprite2D = $Character/Papa_Sprite/Runner_Sprite
@onready var _animation: AnimationPlayer = $Animation_Runner
@onready var _disappear: AnimationPlayer = $Animation_Disappearing_Death
@onready var _bonus_malus_anim: AnimationPlayer = $Animation_Bonus_Malus
@onready var _collider: Area2D = $Character/Papa_Sprite/Runner_Sprite/Collider_Area
@onready var _camera: Camera2D = $Character/Cam

@onready var _footstep1 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_01
@onready var _footstep2 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_02
@onready var _footstep3 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_03

@onready var _teleport_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Teleport
@onready var _dash_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Dash
@onready var _pierce_walls_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Pierce_Walls
@onready var _auto_dodge_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Auto_Dodge
@onready var _invert_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Invert
@onready var _no_turn_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/No_Turn
@onready var _bonus_over_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Bonus_Malus_Over

# which way the runner last moved, be it by running, jumping or sliding
var _direction: Vector2 = Vector2.ZERO

# which way the runner last indicated he WANTED to move
var _last_direction: Vector2 = Vector2.ZERO

# if the runner is mid-jump, which way he is jumping
var _jump_direction: Vector2 = Vector2.ZERO

# if the runner is mid-slide, which way he is sliding
var _slide_direction: Vector2 = Vector2.ZERO

# États
var is_jumping: bool = false
var is_sliding: bool = false
var is_dead: bool = false
var is_falling: bool = false
var is_teleporting: bool = false
var is_one_way: bool = false
var is_exiting: bool = false
var is_dashing: bool = false

const _rotation: float = deg_to_rad(18.4)

var _northwest: Vector2 = Vector2(-1, -1).rotated(-_rotation).normalized()
var _northeast: Vector2 = Vector2(1, -1).rotated(_rotation).normalized()
var _southwest: Vector2 = Vector2(-1, 1).rotated(_rotation).normalized()
var _southeast: Vector2 = Vector2(1, 1).rotated(-_rotation).normalized()

var _map: Map
var _start_cell: Cell
var _curr_cell: Cell
var _curr_cell_pos: Vector2
var _walls: Array[Wall]
var _curr_wall: Wall
var _bonus: Bonus
var _bonus_timer: Timer

func _ready() -> void:
	_animation.animation_finished.connect(_on_animation_finished)
	_disappear.animation_finished.connect(_on_disappear_finished)
	z_index = roundi(global_position.y)
	_camera.update_aim_point(global_position)

	_bonus_timer = Timer.new()
	_bonus_timer.one_shot = true
	_bonus_timer.timeout.connect(_remove_bonus)
	add_child(_bonus_timer)

func set_map(map: Map, start_cell: Cell = null):
	_map = map
	if start_cell:
		_start_cell = start_cell
	else:
		_start_cell = map.get_center_cell()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_x_button"):
		_activate_bonus()

func _physics_process(delta: float):

	# Anything that relies on collision detection is done first, before updating
	# the runner's position, because the physics server has already performed
	# collision detection based on the current position.
	#
	# Collision detection is used in the following cases:
	# - for the walls that arise behind runners
	# - to navigate the central cell's doorway
	# - for one-way signs
	# - for bonus/malus cubes
	#
	# Collision detection is NOT used to determine which cell the runner is on.
	#
	# So first check for collisions with walls, which can be found anywhere.

	if not is_dead:
		for area in _collider.get_overlapping_areas():
			if area.collision_layer & Globals.WALL_LAYER:
				if _has_bonus(Bonus.Type.PIERCE_WALLS):
					if not _pierce_walls_sound.playing:
						_pierce_walls_sound.play()
				else:
					_die(false)
				break

	# Now handle the doorway and one-way signs (which are mutually exclusive:
	# there are no one-way signs in the central cell) and at the same time set
	# the runner's Z-index.
	#
	# The Z-index is set differently when the runner is in the cell with the
	# doorway, as opposed to all other times. Usually, the Z-index is set to the
	# global position in Y, just like pylons, the artefact and the door itself.
	# But in the central cell, when the door is present, the runner's Z-index is
	# set equal to the door's, plus a small offset to ensure he is displayed
	# behind the door, in front of the door, or inbetween the two door frames.

	if not is_dead:

		# In the central cell with the door present: determine where the runner
		# is positioned relative to the two sides of the door and set his
		# Z-index appropriately (in addition to determining if he has made his
		# way through the door).

		var door: Door = _curr_cell.get_door() if _curr_cell else null
		if door:
			match door.get_zone_at(_collider):
				Door.Zone.FRAME:
					if not is_exiting:
						_die(false)
				Door.Zone.PASSAGE:
					if not is_exiting:
						print("we're out!")
						is_exiting = true
					z_index = door.z_index + Door.Depth.MIDDLE
				Door.Zone.BACK:
					z_index = door.z_index + Door.Depth.BACK
				Door.Zone.MIDDLE:
					z_index = door.z_index + Door.Depth.MIDDLE
				Door.Zone.FRONT:
					z_index = door.z_index + Door.Depth.FRONT

		# Otherwise (NOT in the cell with the doorway): check for collisions
		# with one-way signs and bonus/malus cubes, and set the Z-index as
		# usual.

		else:
			z_index = roundi(global_position.y)
			is_exiting = false
			if _curr_cell:
				match _curr_cell.get_state():
					Cell.State.ONE_WAY:
						_check_one_way(_curr_cell)
					Cell.State.CUBE:
						_check_cube(_curr_cell)

	# If the current cell has moved (slid), move the runner with it. Unless he
	# is falling or jumping (but if he were falling, _physics_process() would
	# not have been called).

	if _curr_cell and not is_jumping:
		_set_position(
			position + _curr_cell.global_position - _curr_cell_pos, false,
			_curr_cell)

	# If the runner is dead (but still visible), we're done.

	if is_dead:
		return

	# Find the direction of movement and what would be the runner's new location
	# (cell and position). Note that the cell is determined from the global
	# position WITHOUT collision detection, so it immediately reflects the new
	# position; there is no need to wait for the next physics tick.

	if not (is_jumping or is_sliding or is_one_way or is_dashing
			or _has_bonus(Bonus.Type.NO_TURN)):
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

		if input_direction:
			if _has_bonus(Bonus.Type.INVERT):
				input_direction *= -1
			if is_valid_direction(input_direction):
				_last_direction = input_direction

	var prev_direction = _direction
	if is_jumping:
		_direction = _jump_direction
	elif is_sliding:
		_direction = _slide_direction
	else:
		_direction = _last_direction

	var new_pos = position + _direction * _get_current_speed() * delta
	var new_global_pos = get_parent().to_global(new_pos)
	var new_cell = _map.get_cell_at_pos(new_global_pos)

	# Turn one-way off after leaving the one-way cell. Normally one-way is
	# turned off by _check_one_way() when the runner is no longer in contact
	# with the one-way sign's collider. But if the runner steps directly from
	# that collider to a neighboring cell, or to a space where there is no cell,
	# _check_one_way() will not be called.

	if is_one_way and new_cell != _curr_cell:
		is_one_way = false

	# Check for obstacles at the new location. Note that obstacles may come to
	# the runner even if he has not moved yet.

	var auto_dodge = false

	if new_cell == null:
		if not is_jumping:
			if _has_bonus(Bonus.Type.AUTO_DODGE):
				auto_dodge = true
				_play_jump_animation()
				if not _auto_dodge_sound.playing:
					_auto_dodge_sound.play()
			else:
				_start_falling()
	elif new_cell.get_artefact():
		_die(false)
	else:
		match new_cell.get_state():
			Cell.State.LOWERED, Cell.State.HIDDEN:
				if not is_jumping:
					if _has_bonus(Bonus.Type.AUTO_DODGE):
						auto_dodge = true
						_play_jump_animation()
						if not _auto_dodge_sound.playing:
							_auto_dodge_sound.play()
					else:
						_start_falling()
			Cell.State.TELEPORT:
				_check_teleport(new_cell)
			Cell.State.ONE_WAY:
				# this was already handled above
				pass
			Cell.State.PYLON:
				auto_dodge = _check_pylon(new_cell)

	# Update the position of the runner and the camera, unless the runner hit
	# something inpenetrable (a pylon or artefact), or he has not started to run
	# yet.

	if not (is_dead or is_falling or auto_dodge) and _direction:
		_set_position(new_pos, false, new_cell)

	# Add a point to the runner's wall, unless he is dead, or falling, or
	# jumping, or sliding, or teleporting...

	if is_jumping or is_sliding or is_teleporting or is_dead or is_falling:
		_curr_wall = null
	elif new_cell and _direction:
		_add_to_wall(new_cell, prev_direction)

	# Default animation.

	if not (is_jumping or is_sliding or is_dead or is_falling):
		if _direction == Vector2.ZERO:
			if _last_direction == Vector2.ZERO:
				_animation.play("Intro")
			else:
				if _last_direction.y < 0:
					_animation.play("Start_000")
					_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
				else:
					_animation.play("Start_180")
					_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0
		else:
			if _direction.y < 0:
				_animation.play("Run_000")
				_sprite_node.scale.x = 1.0 if _direction.x < 0 else -1.0
			else:
				_animation.play("Run_180")
				_sprite_node.scale.x = -1.0 if _direction.x < 0 else 1.0

#
# Whenever the runner's position changes, a few other things need to be done as
# well: update his Z-index, update the current cell, remember the cell's current
# position in case it slides, and update the camera to aim at the new position.
#
# Note that the Z-index is NOT updated if the runner is in the central cell and
# the door is present. In that case only, the Z-index is set differently, in
# _physics_process(), so that the runner is displayed behind, inside or in front
# of the door, as appropriate.
#
func _set_position(pos: Vector2, is_global: bool, cell: Cell):
	if is_global:
		global_position = pos
	else:
		position = pos
	if cell == null or cell.get_door() == null:
		z_index = roundi(global_position.y)
	_curr_cell = cell
	if _curr_cell:
		_curr_cell_pos = _curr_cell.global_position
	_camera.update_aim_point(global_position)

func _get_current_speed() -> float:
	if is_jumping and _animation.current_animation.begins_with("Jump_"):
		var progress = (_animation.current_animation_position /
						_animation.current_animation_length)
		return lerp(move_speed, jump_speed, progress)
	elif is_sliding and _animation.current_animation.begins_with("Sliding_"):
		var progress = (_animation.current_animation_position /
						_animation.current_animation_length)
		return lerp(move_speed, slide_speed, progress)
	elif is_dashing:
		return move_speed * 1.66
	else:
		return move_speed

func _play_jump_animation() -> void:
	if _last_direction == Vector2.ZERO or is_dead or is_falling: return
	is_jumping = true
	_jump_direction = _last_direction
	if _last_direction.y < 0:
		_animation.play(&"Jump_000")
		_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
	else:
		_animation.play(&"Jump_180")
		_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0

func _change_jump_direction(new_direction: Vector2):
	if new_direction.y < 0:
		if _animation.current_animation == &"Jump_180":
			_animation.play_section(
				&"Jump_000", _animation.current_animation_position)
		_sprite_node.scale.x = 1.0 if new_direction.x < 0 else -1.0
	else:
		if _animation.current_animation == &"Jump_000":
			_animation.play_section(
				&"Jump_180", _animation.current_animation_position)
		_sprite_node.scale.x = -1.0 if new_direction.x < 0 else 1.0
	_jump_direction = new_direction

func _play_slide_animation() -> void:
	if _last_direction == Vector2.ZERO or is_dead or is_falling: return
	is_sliding = true
	_slide_direction = _last_direction
	if _last_direction.y < 0:
		_animation.play("Sliding_000")
		_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
	else:
		_animation.play("Sliding_180")
		_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0

func _change_slide_direction(new_direction: Vector2):
	if new_direction.y < 0:
		if _animation.current_animation == &"Sliding_180":
			_animation.play_section(
				&"Sliding_000", _animation.current_animation_position)
		_sprite_node.scale.x = 1.0 if new_direction.x < 0 else -1.0
	else:
		if _animation.current_animation == &"Sliding_000":
			_animation.play_section(
				&"Sliding_180", _animation.current_animation_position)
		_sprite_node.scale.x = -1.0 if new_direction.x < 0 else 1.0
	_slide_direction = new_direction

func _die(fast: bool) -> void:
	if is_dead: return
	is_dead = true

	set_process_input(false)

	# If fast is true, the Death and Disappearing animations are played at the
	# same time, and the runner will disappear before the Death animation
	# finishes.
	#
	# Also, if fast is true, the entire wall behind the runner disappears
	# almost immediately. If false, we eliminate only bits of wall that were
	# added recently; the rest of the wall disappears when the runner has
	# disappeared, that is, when the Disappearing animation has finished.

	if fast:
		_disappear.play("Disappearing")
		for wall in _walls:
			wall.disappear()
	else:
		for wall in _walls:
			wall.backup(0.225)

	if _direction.y < 0:
		_animation.play("Death_000")
		_sprite_node.scale.x = 1.0 if _direction.x < 0 else -1.0
	else:
		_animation.play("Death_180")
		_sprite_node.scale.x = -1.0 if _direction.x < 0 else 1.0

func _start_falling() -> void:
	if is_falling or is_dead: return
	is_falling = true

	set_physics_process(false)
	set_process_input(false)

	z_index = RenderingServer.CANVAS_ITEM_Z_MIN

	if _direction.y < 0:
		_animation.play("Falling_000")
		_sprite_node.scale.x = 1.0 if _direction.x < 0 else -1.0
	else:
		_animation.play("Falling_180")
		_sprite_node.scale.x = -1.0 if _direction.x < 0 else 1.0

func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("Jump_"):
		is_jumping = false
		_jump_direction = Vector2.ZERO
	elif anim_name.begins_with("Sliding_"):
		is_sliding = false
		_slide_direction = Vector2.ZERO
	elif anim_name.begins_with("Death_"):
		# if _die(true) was called, then Disappearing has already been played,
		# in which case it will have called set_physics_process(false) already
		if is_physics_processing():
			_disappear.play("Disappearing")
			for wall in _walls:
				wall.disappear()
	elif anim_name.begins_with("Falling_"):
		for wall in _walls:
			wall.disappear()

	# Rien à faire si mort ou en chute (on reste sur l’animation)
	if is_dead or is_falling:
		return

	if _direction != Vector2.ZERO:
		if _direction.y < 0:
			_animation.play("Run_000")
			_sprite_node.scale.x = 1.0 if _direction.x < 0 else -1.0
		else:
			_animation.play("Run_180")
			_sprite_node.scale.x = -1.0 if _direction.x < 0 else 1.0
	else:
		if _last_direction == Vector2.ZERO:
			_animation.play("Intro")
		elif _last_direction.y < 0:
			_animation.play("Start_000")
			_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
		else:
			_animation.play("Start_180")
			_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0

func _on_disappear_finished(_anim_name: String):
	set_physics_process(false)

func is_valid_direction(new_direction: Vector2) -> bool:
	if _last_direction == Vector2.ZERO:
		return true
	return not is_zero_approx(_last_direction.dot(new_direction) + 1.0)

func _check_teleport(cell: Cell):
	var destination = cell.get_teleport_partner()
	if is_teleporting or destination == null:
		return
	is_teleporting = true
	_teleport_sound.play()
	_bonus_malus_anim.play("Bonus_Malus")
	await _bonus_malus_anim.animation_finished
	_set_position(destination.global_position, true, destination)
	_bonus_malus_anim.play("Bonus_Malus")
	if _map:
		await _bonus_malus_anim.animation_finished
		_map.cancel_teleport(destination)
	is_teleporting = false

func _check_one_way(cell: Cell):

	# no overlap with one-way collider: turn one-way off, if it is on, and do
	# nothing

	if not _collider.overlaps_area(cell.get_one_way_collider()):
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

	if is_equal_approx(_direction.dot(new_direction), -1.0):
		_die(false)
		return

	is_one_way = true

	# play the Bonus_Malus animation before actually changing the runner's
	# direction, then again, and finally remove the one-way obstacle

	_bonus_malus_anim.play("Bonus_Malus")
	await _bonus_malus_anim.animation_finished
	_last_direction = new_direction
	if is_jumping:
		_change_jump_direction(new_direction)
	elif is_sliding:
		_change_slide_direction(new_direction)
	_bonus_malus_anim.play("Bonus_Malus")
	if _map:
		_map.cancel_one_way(cell)

func _check_pylon(cell: Cell) -> bool:
	# if the runner was already on the cell when the pylon is lowered or
	# dropped, he just disappears: see _die()
	match cell.get_pylon().get_state():
		Pylon.State.LOWERED:
			if not is_sliding:
				if _has_bonus(Bonus.Type.AUTO_DODGE):
					_play_slide_animation()
					if not _auto_dodge_sound.playing:
						_auto_dodge_sound.play()
					return true
				_die(cell == _curr_cell)
		Pylon.State.DROPPED:
			_die(cell == _curr_cell)
	return false

func _check_cube(cell: Cell):
	var cube: Cube = cell.get_cube()
	if cube and cube.check_for_overlap(_collider):
		print("bonus/malus: ", Bonus.Type.keys()[cube.bonus_type].capitalize())

		# take the cube's bonus and remove the cube from its cell

		_bonus_timer.stop()
		_bonus = cube.get_bonus()
		_bonus_malus_anim.play("Bonus_Malus")
		cell.remove_cube()

		# automatic => activate the bonus/malus right away
		# otherwise => give the runner 30 seconds to activate it

		if _bonus.is_automatic():
			_activate_bonus()
		else:
			cube.play_grab_sound()
			_sprite.set_instance_shader_parameter(&"outline_color", Color.BLACK)
			_bonus_timer.start(30)

func _activate_bonus():
	if _bonus == null:
		return

	# Dash is the only bonus that can be "activated" several times before it
	# expires

	if _bonus.is_activated:
		if _bonus.type == Bonus.Type.DASH:
			_start_dash()
		return

	print("activate ", Bonus.Type.keys()[_bonus.type].capitalize())

	# activate the bonus: set the runner's outline color and make him blink

	_bonus.is_activated = true
	_sprite.set_instance_shader_parameter(
		&"outline_color", _get_outline_color())
	_bonus_malus_anim.play(&"Bonus_Malus")

	# sound effect

	match _bonus.type:
		Bonus.Type.PIERCE_WALLS:
			_pierce_walls_sound.play()
		Bonus.Type.AUTO_DODGE:
			_auto_dodge_sound.play()
		Bonus.Type.INVERT:
			_invert_sound.play()
		Bonus.Type.NO_TURN:
			_no_turn_sound.play()

	# positive duration => bonus will be removed after the time elapses
	# otherwise => bonus is removed as soon as the runner stops blinking

	var duration = _bonus.get_duration()
	if duration > 0:
		_bonus_timer.start(duration)
	else:
		_bonus_timer.stop()
		await _bonus_malus_anim.animation_finished
		_remove_bonus()

	# when Dash is activated, start the first dash automatically

	if _bonus.type == Bonus.Type.DASH:
		_start_dash()

func _start_dash():
	if is_dashing or is_jumping or is_falling:
		return
	if not _dash_sound.playing:
		_dash_sound.play()
	_animation.speed_scale = 1.66
	is_dashing = true
	get_tree().create_timer(0.5).timeout.connect(_stop_dash)

func _stop_dash():
	_animation.speed_scale = 1
	is_dashing = false

func _has_bonus(type: Bonus.Type) -> bool:
	return _bonus and _bonus.type == type and _bonus.is_activated

func _remove_bonus():
	if _bonus:
		_bonus = null
		_bonus_over_sound.play()
		_bonus_malus_anim.play(&"Bonus_Malus")
		await _bonus_malus_anim.animation_finished
		_sprite.set_instance_shader_parameter(&"outline_color", Color.BLACK)

func _get_outline_color() -> Color:
	if _bonus:
		match _bonus.type:
			Bonus.Type.INVINCIBLE, Bonus.Type.INVERT:
				return Color(1, 0.25, 0.25)
			Bonus.Type.DASH, Bonus.Type.ANTI_DASH:
				return Color(0.15, 0.88, 0.15)
			Bonus.Type.PIERCE_WALLS, Bonus.Type.PHASE:
				return Color(0.378, 0.378, 0.86)
			Bonus.Type.VIRUS, Bonus.Type.ANTI_VIRUS:
				return Color(0.625, 0.29, 0.88)
			Bonus.Type.AUTO_DODGE, Bonus.Type.NO_TURN:
				return Color(0.83, 0.83, 0.0)
			Bonus.Type.DEBUG, Bonus.Type.SLOW:
				return Color(0.45, 0.45, 0.45)
			Bonus.Type.VANISH_WALLS, Bonus.Type.EXTEND_WALLS:
				return Color(0.75, 0.75, 0.75)
	return Color.BLACK

#
# Methods called by run cycle animation.
#
func play_foot_step_01():
	_footstep1.play()

func play_foot_step_02():
	_footstep2.play()

func play_foot_step_03():
	_footstep3.play()

func _add_to_wall(new_cell: Cell, prev_direction: Vector2):
	var is_same_dir = (_direction == prev_direction)
	var wall: Wall

	# add to previous wall if there is one and we have not left its cell or
	# changed direction

	if _curr_wall and _curr_wall.cell == new_cell and is_same_dir:
		wall = _curr_wall

	# otherwise create a new wall and attach it to the given cell

	else:
		wall = new_cell.add_wall()
		wall.gone.connect(func(): _walls.erase(wall))
		_walls.push_back(wall)

		# if there is already a wall in progress, we may need to interrupt it
		# and create a new one if the runner changes direction or moves to a
		# different cell

		if _curr_wall:
			var last_cell: Cell = _curr_wall.cell
			var last_point: Vector2 = _curr_wall.get_last_point()

			# change of direction only: start the new wall where the previous
			# wall ends

			if last_cell == new_cell:
				wall.add_point(last_point)

			# change of cell only: finish the previous wall and start the new
			# one with a point at the intersection of the neighboring cells

			elif is_same_dir:
				var intersection = last_cell.get_exit_point(
					last_point, global_position)
				if intersection:
					_curr_wall.add_point(intersection)
					wall.add_point(intersection)
				else:
					wall.add_point(last_point)

			# change of cell AND direction: we need a tiny, single-segment wall
			# to go to the edge of the cell

			else:
				var intersection = last_cell.get_exit_point(
					last_point, global_position)
				if intersection:
					var gap_wall: Wall = last_cell.add_wall()
					gap_wall.gone.connect(func(): _walls.erase(gap_wall))
					_walls.push_back(gap_wall)
					gap_wall.add_point(last_point)
					gap_wall.add_point(intersection)
					wall.add_point(intersection)
				else:
					wall.add_point(last_point)

		# otherwise, this is the start of a new wall, so play its Appearing
		# animation

		else:
			get_tree().create_timer(Wall.delay).timeout.connect(wall.appear)

		_curr_wall = wall

	# add the current position to the current wall

	wall.add_point(global_position)
