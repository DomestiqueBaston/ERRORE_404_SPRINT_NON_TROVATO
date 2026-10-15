class_name Runner extends Node2D

@export var move_speed: float = 395.0
@export var jump_speed: float = 375.0
@export var slide_speed: float = 375.0

## If non-negative, input events from other devices are ignored.
var input_device: int = -1

## Which direction the runner is moving, be it by running, jumping or sliding.
var direction: Vector2 = Vector2.ZERO

## Signal emitted when the runner has died.
signal died

## Signal emitted when the runner has escaped through the exit door.
signal escaped

## Signal emitted when the runner grabs a bonus which affects other runners.
signal bonus_found(bonus: Bonus)

## Signal emitted when a visual bug is triggered for the runner.
signal start_bug(bug: Globals.Bug)

## Signal emitted when a visual bug is turned off for the runner.
signal stop_bug(bug: Globals.Bug)

@onready var _sprite_node: Node2D = $Character/Papa_Sprite
@onready var _sprite: Sprite2D = $Character/Papa_Sprite/Runner_Sprite
@onready var _animation: AnimationPlayer = $Animation_Runner
@onready var _disappear_anim: AnimationPlayer = $Animation_Disappearing_Death
@onready var _bonus_malus_anim: AnimationPlayer = $Animation_Bonus_Malus
@onready var _glitch_anim: AnimationPlayer = $Animation_Glitch
@onready var _collider: Area2D = $Character/Papa_Sprite/Runner_Sprite/Collider_Area
@onready var _vision: Area2D = $Character/Papa_Sprite/Runner_Sprite/Vision_Area
@onready var _vision_shape: CollisionPolygon2D = $Character/Papa_Sprite/Runner_Sprite/Vision_Area/Vision

@onready var _footstep1 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_01
@onready var _footstep2 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_02
@onready var _footstep3 = $Character/Papa_Sprite/Runner_Sprite/Sound/Foot_Step_03

@onready var _teleport_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Teleport
@onready var _bonus_over_sound = $Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Bonus_Malus_Over

@onready var _bonus_sounds = {
	Bonus.Type.INVINCIBLE:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Invincible,
	Bonus.Type.DASH:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Dash,
	Bonus.Type.PIERCE_WALLS:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Pierce_Walls,
	Bonus.Type.VIRUS:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Virus,
	Bonus.Type.AUTO_DODGE:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Auto_Dodge,
	Bonus.Type.DEBUG:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Debug,
	Bonus.Type.VANISH_WALLS:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Vanish_Walls,
	Bonus.Type.INVERT:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Invert,
	Bonus.Type.SLOW:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Slow,
	Bonus.Type.EXTEND_WALLS:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Extend_Walls,
	Bonus.Type.ANTI_DASH:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Anti_Dash,
	Bonus.Type.PHASE:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Phase,
	Bonus.Type.ANTI_VIRUS:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/Anti_Virus,
	Bonus.Type.NO_TURN:
		$Character/Papa_Sprite/Runner_Sprite/Sound/Bonus_Malus/No_Turn
}

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

# player commands that are delayed by the slow malus

enum DelayedCmd {
	NONE,
	JUMP,
	SLIDE
}
var _delayed_command: DelayedCmd = DelayedCmd.NONE
var _is_left_pressed: bool = false
var _is_right_pressed: bool = false
var _is_up_pressed: bool = false
var _is_down_pressed: bool = false

var _map: Map
var _camera: Camera2D
var _start_cell: Cell
var _curr_cell: Cell
var _curr_cell_pos: Vector2
var _walls: Array[Wall]
var _are_walls_vanishing: bool = false
var _curr_wall: Wall
var _bonus: Bonus
var _bonus_timer: Timer
var _curr_bug: Globals.Bug = Globals.Bug.NONE
var _bug_timer: Timer

func _ready() -> void:
	_animation.animation_finished.connect(_on_animation_finished)
	_disappear_anim.animation_finished.connect(_on_disappear_finished)

	z_index = roundi(global_position.y)

	_bonus_timer = Timer.new()
	_bonus_timer.one_shot = true
	_bonus_timer.timeout.connect(_remove_bonus)
	add_child(_bonus_timer)

	_bug_timer = Timer.new()
	_bug_timer.one_shot = true
	_bug_timer.timeout.connect(_on_bug_timer_timeout)
	add_child(_bug_timer)
	_bug_timer.start(_get_bug_frequency())

	_collider.area_entered.connect(_on_collider_entered)

##
## Sets up the runner's environment: the Map he will be running around, the
## corner of the Map where he will be positioned initially, and the camera that
## will track his movements.
##
func set_environment(map: Map, start_corner: Globals.Corner, camera: Camera2D):
	_map = map
	_camera = camera

	var sz = map.map_size
	match start_corner:
		Globals.Corner.N:
			_start_cell = map.get_cell_at(Vector2i(-sz, sz))
			if camera:
				camera.offset = Vector2(0, 15)
		Globals.Corner.S:
			_start_cell = map.get_cell_at(Vector2i(sz, -sz))
			if camera:
				camera.offset = Vector2(0, -75)
		Globals.Corner.W:
			_start_cell = map.get_cell_at(Vector2i(-sz, -sz))
			if camera:
				camera.offset = Vector2(120, -40)
		Globals.Corner.E:
			_start_cell = map.get_cell_at(Vector2i(sz, sz))
			if camera:
				camera.offset = Vector2(-120, -40)

	position = _start_cell.position + Cell.get_start_cell_offset(start_corner)
	if camera:
		camera.global_position = global_position

func _input(event: InputEvent):
	if not event.is_action_type():
		return

	# If a specific input device was specified for this runner, ignore other
	# input devices. As a special case, the keyboard is also accepted if device
	# 0 was specified.

	if input_device >= 0:
		if input_device == 0:
			if not event.device in [0, InputEvent.DEVICE_ID_KEYBOARD]:
				return
		else:
			if event.device != input_device:
				return

	if event.is_action_pressed(&"ui_left_button"):
		await _apply_slow_delay()
		_is_left_pressed = true
	elif event.is_action_released(&"ui_left_button"):
		await _apply_slow_delay()
		_is_left_pressed = false
	elif event.is_action_pressed(&"ui_right_button"):
		await _apply_slow_delay()
		_is_right_pressed = true
	elif event.is_action_released(&"ui_right_button"):
		await _apply_slow_delay()
		_is_right_pressed = false
	elif event.is_action_pressed(&"ui_up_button"):
		await _apply_slow_delay()
		_is_up_pressed = true
	elif event.is_action_released(&"ui_up_button"):
		await _apply_slow_delay()
		_is_up_pressed = false
	elif event.is_action_pressed(&"ui_down_button"):
		await _apply_slow_delay()
		_is_down_pressed = true
	elif event.is_action_released(&"ui_down_button"):
		await _apply_slow_delay()
		_is_down_pressed = false
	elif event.is_action_pressed(&"ui_a_button"):
		await _apply_slow_delay()
		_delayed_command = DelayedCmd.JUMP
	elif event.is_action_pressed(&"ui_b_button"):
		await _apply_slow_delay()
		_delayed_command = DelayedCmd.SLIDE
	elif event.is_action_pressed(&"ui_x_button"):
		if _has_bonus(Bonus.Type.DASH):
			_start_dash()

func _apply_slow_delay():
	if _has_bonus(Bonus.Type.SLOW):
		await get_tree().create_timer(0.15).timeout

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
					if not _bonus_sounds[Bonus.Type.PIERCE_WALLS].playing:
						_bonus_sounds[Bonus.Type.PIERCE_WALLS].play()
				else:
					_die()
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
						_die()
				Door.Zone.PASSAGE:
					if not is_exiting:
						is_exiting = true
						print("%s is out!" % name)
						escaped.emit()
						set_process_input(false)
						_bonus_malus_anim.play(&"Bonus_Malus")
						await _bonus_malus_anim.animation_finished
						_disappear()
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

		if _delayed_command == DelayedCmd.JUMP:
			_play_jump_animation()
		elif _delayed_command == DelayedCmd.SLIDE:
			_play_slide_animation()
		elif Globals.use_diagonals_for_movement:
			if _is_left_pressed:
				if _is_down_pressed:
					input_direction = Globals.SOUTHWEST
				elif _is_up_pressed:
					input_direction = Globals.NORTHWEST
			elif _is_right_pressed:
				if _is_down_pressed:
					input_direction = Globals.SOUTHEAST
				elif _is_up_pressed:
					input_direction = Globals.NORTHEAST
		else:
			if _is_left_pressed:
				input_direction = Globals.NORTHWEST
			elif _is_up_pressed:
				input_direction = Globals.NORTHEAST
			elif _is_right_pressed:
				input_direction = Globals.SOUTHEAST
			elif _is_down_pressed:
				input_direction = Globals.SOUTHWEST

		if input_direction:
			if _has_bonus(Bonus.Type.INVERT):
				input_direction *= -1
			if _is_valid_direction(input_direction):
				_last_direction = input_direction

	_delayed_command = DelayedCmd.NONE

	var prev_direction = direction
	if is_jumping:
		direction = _jump_direction
	elif is_sliding:
		direction = _slide_direction
	else:
		direction = _last_direction

	var new_pos = position + direction * get_current_speed() * delta
	var parent = get_parent()
	var new_global_pos = parent.to_global(new_pos) if parent is Node2D else new_pos
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
				if not _bonus_sounds[Bonus.Type.AUTO_DODGE].playing:
					_bonus_sounds[Bonus.Type.AUTO_DODGE].play()
			else:
				_start_falling()
	elif new_cell.get_artefact():
		_die()
	else:
		match new_cell.get_state():
			Cell.State.LOWERED, Cell.State.HIDDEN:
				if not is_jumping:
					if _has_bonus(Bonus.Type.AUTO_DODGE):
						auto_dodge = true
						_play_jump_animation()
						if not _bonus_sounds[Bonus.Type.AUTO_DODGE].playing:
							_bonus_sounds[Bonus.Type.AUTO_DODGE].play()
					else:
						_start_falling()
			Cell.State.TELEPORT:
				_check_teleport(new_cell)
			Cell.State.ONE_WAY:
				# this was already handled above
				pass
			Cell.State.PYLON:
				auto_dodge = _check_pylon(new_cell)

	# Update the position of the runner, unless the runner hit something
	# inpenetrable (a pylon or artefact), or he has not started to run yet.
	# If he has changed direction, change the camera offset, too.

	if not (is_dead or is_falling or auto_dodge) and direction:
		_set_position(new_pos, false, new_cell)
		if (_camera and direction != prev_direction
			and _curr_bug != Globals.Bug.CAMERA_OFFSET):
			var offset: Vector2
			offset.x = -100 if direction.x < 0 else 100
			offset.y = -85 if direction.y < 0 else 30
			create_tween() \
				.set_trans(Tween.TRANS_SINE) \
				.set_ease(Tween.EASE_IN_OUT) \
				.tween_property(_camera, ^"offset", offset, 0.666)

	# Add a point to the runner's wall, unless he is dead, or falling, or
	# jumping, or sliding, or teleporting...

	if (new_cell and new_cell.can_take_wall() and direction and
		not (is_jumping or is_sliding or is_teleporting
			 or is_dead or is_falling or is_exiting or _are_walls_vanishing)):
		_add_to_wall(new_cell, prev_direction)
	else:
		_curr_wall = null

	# Default animation.

	if not (is_jumping or is_sliding or is_dead or is_falling):
		if direction == Vector2.ZERO:
			if _last_direction == Vector2.ZERO:
				_animation.play(&"Intro")
			else:
				if _last_direction.y < 0:
					_animation.play(&"Start_000")
					_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
				else:
					_animation.play(&"Start_180")
					_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0
		else:
			if direction.y < 0:
				_animation.play(&"Run_000")
				_sprite_node.scale.x = 1.0 if direction.x < 0 else -1.0
			else:
				_animation.play(&"Run_180")
				_sprite_node.scale.x = -1.0 if direction.x < 0 else 1.0

#
# Whenever the runner's position changes, a few other things need to be done as
# well: update his Z-index, update the current cell, remember the cell's
# current position in case it slides, and update the camera position.
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
	if _camera:
		_camera.global_position = global_position

##
## Returns the cell where the runner is currently located, if known.
##
func get_current_cell() -> Cell:
	return _curr_cell

##
## Returns true if the runner is still alive and running.
##
func is_alive() -> bool:
	return not (is_dead or is_falling or is_exiting)

##
## Returns the speed at which the runner is currently moving, in units/second.
##
func get_current_speed() -> float:
	var speed: float
	if is_jumping and _animation.current_animation.begins_with("Jump_"):
		var progress = (_animation.current_animation_position /
						_animation.current_animation_length)
		speed = lerp(move_speed, jump_speed, progress)
	elif is_sliding and _animation.current_animation.begins_with("Sliding_"):
		var progress = (_animation.current_animation_position /
						_animation.current_animation_length)
		speed = lerp(move_speed, slide_speed, progress)
	else:
		speed = move_speed
	return speed * _animation.speed_scale

##
## Returns the visual bug currently affecting the runner, if any.
##
func get_current_bug() -> Globals.Bug:
	return _curr_bug

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
		_animation.play(&"Sliding_000")
		_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
	else:
		_animation.play(&"Sliding_180")
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

func _die(fast: bool = false) -> void:
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
		_disappear()
		died.emit()
	else:
		for wall in _walls:
			wall.backup(0.225)

	if direction.y < 0:
		_animation.play(&"Death_000")
		_sprite_node.scale.x = 1.0 if direction.x < 0 else -1.0
	else:
		_animation.play(&"Death_180")
		_sprite_node.scale.x = -1.0 if direction.x < 0 else 1.0

func _start_falling() -> void:
	if is_falling or is_dead: return
	is_falling = true

	set_physics_process(false)
	set_process_input(false)

	z_index = RenderingServer.CANVAS_ITEM_Z_MIN

	if direction.y < 0:
		_animation.play(&"Falling_000")
		_sprite_node.scale.x = 1.0 if direction.x < 0 else -1.0
	else:
		_animation.play(&"Falling_180")
		_sprite_node.scale.x = -1.0 if direction.x < 0 else 1.0

func _disappear():
	_disappear_anim.play(&"Disappearing")
	_collider.monitorable = false
	for wall in _walls:
		wall.disappear()
	set_process_input(false)

func _on_animation_finished(anim_name: StringName) -> void:
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
			_disappear()
			died.emit()
	elif anim_name.begins_with(&"Falling_"):
		_disappear()
		died.emit()

	# Rien à faire si mort ou en chute (on reste sur l’animation)
	if is_dead or is_falling:
		return

	if direction != Vector2.ZERO:
		if direction.y < 0:
			_animation.play(&"Run_000")
			_sprite_node.scale.x = 1.0 if direction.x < 0 else -1.0
		else:
			_animation.play(&"Run_180")
			_sprite_node.scale.x = -1.0 if direction.x < 0 else 1.0
	else:
		if _last_direction == Vector2.ZERO:
			_animation.play(&"Intro")
		elif _last_direction.y < 0:
			_animation.play(&"Start_000")
			_sprite_node.scale.x = 1.0 if _last_direction.x < 0 else -1.0
		else:
			_animation.play(&"Start_180")
			_sprite_node.scale.x = -1.0 if _last_direction.x < 0 else 1.0

func _on_disappear_finished(_anim_name: String):
	set_physics_process(false)

#
# Returns true if the runner can run in the given direction, that is, if it is
# not opposite to the direction he is running now (the runner can only turn
# left or right).
#
func _is_valid_direction(new_direction: Vector2) -> bool:
	if _last_direction == Vector2.ZERO:
		return true
	return not is_zero_approx(_last_direction.dot(new_direction) + 1.0)

func _check_teleport(cell: Cell):
	var destination = cell.get_teleport_partner()
	if is_teleporting or destination == null:
		return
	is_teleporting = true
	_teleport_sound.play()
	_bonus_malus_anim.play(&"Bonus_Malus")
	await _bonus_malus_anim.animation_finished
	_set_position(destination.global_position, true, destination)
	_bonus_malus_anim.play(&"Bonus_Malus")
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
			new_direction = Globals.NORTHWEST
		Globals.Axis.NE:
			new_direction = Globals.NORTHEAST
		Globals.Axis.SW:
			new_direction = Globals.SOUTHWEST
		Globals.Axis.SE:
			new_direction = Globals.SOUTHEAST

	# if the runner is going the opposite direction, kill him

	if is_equal_approx(direction.dot(new_direction), -1.0):
		_die()
		return

	is_one_way = true

	# play the Bonus_Malus animation before actually changing the runner's
	# direction, then again, and finally remove the one-way obstacle

	_bonus_malus_anim.play(&"Bonus_Malus")
	await _bonus_malus_anim.animation_finished
	_last_direction = new_direction
	if is_jumping:
		_change_jump_direction(new_direction)
	elif is_sliding:
		_change_slide_direction(new_direction)
	_bonus_malus_anim.play(&"Bonus_Malus")
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
					if not _bonus_sounds[Bonus.Type.AUTO_DODGE].playing:
						_bonus_sounds[Bonus.Type.AUTO_DODGE].play()
					return true
				_die(cell == _curr_cell)
		Pylon.State.DROPPED:
			_die(cell == _curr_cell)
	return false

func _check_cube(cell: Cell):
	var cube: Cube = cell.get_cube()
	if cube and cube.check_for_overlap(_collider):
		print("%s: %s bonus/malus" % [
			name, Bonus.Type.keys()[cube.bonus_type].capitalize()])
		var new_bonus = cube.get_bonus()
		cell.remove_cube()
		apply_bonus(new_bonus)

##
## Call this function to apply a bonus/malus, replacing whatever bonus the
## runner may already have.
##
func apply_bonus(new_bonus: Bonus):

		# cancel the current bonus

		var old_bonus_type = _bonus.type if _bonus else -1
		_bonus_timer.stop()
		_remove_bonus(false)

		# the invincible bonus cancels out a new malus

		if old_bonus_type == Bonus.Type.INVINCIBLE and not new_bonus.is_bonus():
			_bonus_sounds[old_bonus_type].play()

		# the virus bonus sends a new malus to somebody else;
		# the anti-virus malus sends a new bonus to somebody else

		elif ((old_bonus_type == Bonus.Type.VIRUS and not new_bonus.is_bonus()) or
			  (old_bonus_type == Bonus.Type.ANTI_VIRUS and new_bonus.is_bonus())):
			_bonus_sounds[old_bonus_type].play()
			bonus_found.emit(new_bonus)

		# VANISH_WALLS and EXTEND_WALLS are handled by The Game, not the runner

		elif new_bonus.type in [
			Bonus.Type.VANISH_WALLS, Bonus.Type.EXTEND_WALLS
		]:
			_bonus_sounds[new_bonus.type].play()
			bonus_found.emit(new_bonus)

		# all other cases: activate the bonus/malus

		else:
			_bonus = new_bonus
			_activate_bonus()

func _activate_bonus():
	if _bonus == null:
		return

	# activate the bonus: set the runner's outline color and make him blink

	_sprite.set_instance_shader_parameter(
		&"outline_color", _get_outline_color())
	_bonus_malus_anim.play(&"Bonus_Malus")

	# sound effect

	_bonus_sounds[_bonus.type].play()

	# bonus-specific behavior

	match _bonus.type:
		Bonus.Type.DEBUG:
			_reset_bug()
		Bonus.Type.ANTI_DASH:
			_start_anti_dash()
		Bonus.Type.PHASE:
			_glitch_anim.play(&"Glitch")

	# positive duration => bonus will be removed after the time elapses
	# otherwise => bonus is removed as soon as the runner stops blinking

	var duration = _bonus.get_duration()
	if duration > 0:
		_bonus_timer.start(duration)
	else:
		_bonus_timer.stop()
		await _bonus_malus_anim.animation_finished
		_remove_bonus()

func _start_dash():
	if is_dashing or is_jumping or is_falling:
		return
	if not _bonus_sounds[Bonus.Type.DASH].playing:
		_bonus_sounds[Bonus.Type.DASH].play()
	_animation.speed_scale = 1.66
	is_dashing = true
	get_tree().create_timer(0.5).timeout.connect(_stop_dash)

func _stop_dash():
	_animation.speed_scale = 1
	is_dashing = false

func _start_anti_dash():
	create_tween().tween_property(_animation, "speed_scale", 0.85, 0.5)

func _stop_anti_dash():
	_animation.speed_scale = 1

func has_bonus():
	return _bonus != null

func _has_bonus(type: Bonus.Type) -> bool:
	return _bonus and _bonus.type == type

func _remove_bonus(with_sound_effect: bool = true):
	if _bonus == null:
		return

	var bonus_type = _bonus.type
	_bonus = null

	if not (is_dead or is_falling):
		match bonus_type:
			Bonus.Type.DASH:
				_stop_dash()
			Bonus.Type.ANTI_DASH:
				_stop_anti_dash()
			Bonus.Type.PHASE:
				_glitch_anim.play(&"RESET")
		if with_sound_effect:
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
				return Color(0.713, 0.29, 0.88)
			Bonus.Type.AUTO_DODGE, Bonus.Type.NO_TURN:
				return Color(0.83, 0.83, 0.0)
			Bonus.Type.DEBUG, Bonus.Type.SLOW:
				return Color(0.55, 0.55, 0.55)
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
	var is_same_dir = (direction == prev_direction)
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

func _on_collider_entered(area: Area2D):
	if area.collision_layer & Globals.RUNNER_LAYER:
		if not (is_dead or is_falling):
			_die()

##
## Returns an array of any other runners that are visible to this one, that is,
## whose ground colliders overlap this runner's vision collider.
##
func get_visible_runners() -> Array[Runner]:
	var runners: Array[Runner]
	for area in _vision.get_overlapping_areas():
		if area != _collider and (area.collision_layer & Globals.RUNNER_LAYER):
			var runner = area.get_node("../../../..")
			if runner is Runner:
				runners.append(runner)
	return runners

##
## Applies a scale factor to the runner's vision area collider shape, limiting
## what he sees if the scale factor is less than 1.
##
func set_vision_area_scale(sc: float):
	_vision_shape.scale = Vector2(sc, sc)

##
## Makes all the walls generated so far by this runner vanish. Once they have
## disappeared, the runner starts generating walls again.
##
func vanish_walls():
	if _are_walls_vanishing or _walls.is_empty():
		return
	_are_walls_vanishing = true
	for i in _walls.size() - 1:
		_walls[i].disappear()
	await _walls.back().disappear()
	_are_walls_vanishing = false

##
## Makes all the walls generated by this runner last longer for a while.
##
func extend_walls():
	for wall in _walls:
		wall.extend()

#
# Frequency at which we decide whether to trigger a bug.
#
func _get_bug_frequency() -> float:
	# 1.25-2.5 seconds, inversely proportional to difficulty
	return 2.5 - 1.25 * (mini(5, Globals.difficulty) - 1) / 4.0

#
# How long a bug lasts.
#
func _get_bug_duration() -> float:
	# 0.75 -> 2.5 seconds, proportional to difficulty
	return 0.75 + 1.75 * (mini(5, Globals.difficulty) - 1) / 4.0

#
# Called when the bug timer times out, either because it's time to stop the
# current bug or because it may be time to trigger a new one.
#
func _on_bug_timer_timeout():
	if _curr_bug != Globals.Bug.NONE:
		_reset_bug()
		return

	if not _has_bonus(Bonus.Type.DEBUG) and randi() % 5 == 0:
		_curr_bug = randi_range(1, Globals.Bug.size() - 1) as Globals.Bug
		if _curr_bug == Globals.Bug.CAMERA_OFFSET:
			if _camera:
				_camera.offset = Vector2(0, 0)
		else:
			start_bug.emit(_curr_bug)
		_bug_timer.start(_get_bug_duration())
	elif not (is_dead or is_falling):
		_bug_timer.start(_get_bug_frequency())

#
# Stops the bug that is currently running, if there is one.
#
func _reset_bug():
	if _curr_bug != Globals.Bug.NONE:
		if _curr_bug != Globals.Bug.CAMERA_OFFSET:
			stop_bug.emit(_curr_bug)
		_curr_bug = Globals.Bug.NONE
		if not (is_dead or is_falling):
			_bug_timer.start(_get_bug_frequency())
