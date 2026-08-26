extends Node2D

## La Vision_Area n'est pas gérée par ce script,
## c'est juste de la démo...

@onready var sprite: Node2D = $Character/Papa_Sprite
@onready var animation_player: AnimationPlayer = $Animation_Runner
@onready var collider: Area2D = $Character/Papa_Sprite/Runner_Sprite/Collider_Area

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

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

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
		# back up if the runner hit a pylon or the raised central cell
		position += direction * _get_current_speed() * -delta

	# États bloquants : plus rien à faire
	if is_dead or is_falling:
		return

	if not is_jumping and not is_sliding:
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
	position += direction * _get_current_speed() * delta

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
	
	# no more movement
	set_physics_process(false)
	
	if fast:
		$Animation_Disappearing_Death.play("Disappearing")
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
		$Animation_Disappearing_Death.play("Disappearing")

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

func is_valid_direction(new_direction: Vector2) -> bool:
	if last_direction == Vector2.ZERO:
		return true
	return not is_zero_approx(last_direction.dot(new_direction) + 1.0)

#
# Checks whether the runner's location (current cell) has changed, and if he
# has encountered an obstacle, or a teleport, or fallen off the map, etc. On
# return, he may be dead or falling.
#
# Returns true if the runner died after running into a pylon or the raised
# central cell.
#
func _check_location() -> bool:
	if _map == null:
		return false

	# find the cell underfoot

	var next_cell: Cell = _map.get_cell_in_area(collider)

	# update the current cell accordingly and check for obstacles

	if next_cell:
		match next_cell.get_state():
			Cell.State.LOWERED, Cell.State.HIDDEN:
				if not is_jumping:
					start_falling()
			Cell.State.RAISED:
				die(false)
			Cell.State.TELEPORT:
				_check_teleport(next_cell)
			Cell.State.ONE_WAY:
				_check_one_way(next_cell)
			Cell.State.PYLON:
				_check_pylon(next_cell)
	else:
		if not is_jumping:
			start_falling()

	# did the runner run into a pylon or the raised central cell?

	var backup = is_dead and _curr_cell != next_cell

	# if the runner hasn't moved to a different cell and the cell is moving,
	# move the runner with it

	if _curr_cell and _curr_cell == next_cell and not (is_falling or is_jumping):
		position += _curr_cell.global_position - _curr_cell_pos

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
	is_teleporting = false
	anim.play("Bonus_Malus")
	if _map:
		await anim.animation_finished
		_map.cancel_teleport(destination)

func _check_one_way(cell: Cell):
	if not collider.overlaps_area(cell.get_one_way_collider()):
		return
	var anim: AnimationPlayer = $Animation_Bonus_Malus
	anim.play("Bonus_Malus")
	await anim.animation_finished
	match cell.get_one_way_direction():
		Globals.Axis.NW:
			last_direction = _northwest
		Globals.Axis.NE:
			last_direction = _northeast
		Globals.Axis.SW:
			last_direction = _southwest
		Globals.Axis.SE:
			last_direction = _southeast
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
