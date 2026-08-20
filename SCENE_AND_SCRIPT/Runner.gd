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
@export var slide_speed: float = 365.0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var last_non_zero_direction: Vector2 = Vector2.ZERO

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
var _has_left_center: bool = false
var _curr_cell: Cell
var _curr_cell_pos: Vector2

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

func set_map(map: Map):
	_map = map

func _process(delta: float) -> void:
	# États bloquants : plus rien à faire
	if is_dead or is_falling:
		return

	var input_direction := Vector2.ZERO

	# ── MORT AVEC X ──
	if Input.is_action_just_pressed("ui_x_button"):
		die()
		return

	# ── CHUTE AVEC Y ──
	if Input.is_action_just_pressed("ui_y_button"):
		start_falling()
		return

	# SAUT (A)
	if Input.is_action_just_pressed("ui_a_button") and not is_jumping and not is_sliding:
		_play_jump_animation()

	# SLIDE (B)
	if Input.is_action_just_pressed("ui_b_button") and not is_jumping and not is_sliding:
		_play_slide_animation()

	# === Entrées de déplacement ===
	if not is_jumping and not is_sliding:
		if Globals.use_diagonals_for_movement:
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
				input_direction = _southwest
			elif Input.is_action_pressed("ui_up_button"):
				input_direction = _northwest
			elif Input.is_action_pressed("ui_right_button"):
				input_direction = _northeast
			elif Input.is_action_pressed("ui_down_button"):
				input_direction = _southeast

		if input_direction and is_valid_direction(input_direction):
			last_direction = input_direction
			last_non_zero_direction = input_direction

	# === Direction actuelle ===
	if is_jumping:
		direction = jump_direction
	elif is_sliding:
		direction = slide_direction
	else:
		direction = last_direction

	# === Vitesse dynamique ===
	var current_speed: float = move_speed
	var anim := animation_player.current_animation
	if anim.begins_with("Jump_"):
		var progress := animation_player.current_animation_position / animation_player.current_animation_length
		current_speed = lerp(move_speed, jump_speed, progress)
	elif anim.begins_with("Sliding_"):
		var progress := animation_player.current_animation_position / animation_player.current_animation_length
		current_speed = lerp(move_speed, slide_speed, progress)

	# === Mouvement (bloqué si mort ou en chute) ===
	if not is_dead and not is_falling and direction:
		position += direction * current_speed * delta

	# Figure out which cell of the map the runner is on, if any. If the cell is
	# moving, move the runner along with it. If it is a teleport cell, then
	# teleport to the partner cell.

	if _map:

		# Find the cell underfoot. Note that get_cell_at() returns null if the
		# runner has not left the center cell yet!

		var next_cell: Cell = _map.get_cell_at(collider)
		if not _has_left_center:
			if next_cell == null:
				next_cell = _map.get_center_cell()
			else:
				_has_left_center = true

		# If we haven't moved to a different cell, just add the current cell's
		# movement to the runner's.

		if _curr_cell == next_cell:
			if _curr_cell and not is_falling and not is_jumping:
				var next_cell_pos = _curr_cell.global_position
				position += next_cell_pos - _curr_cell_pos

		# If we have moved to a different cell (or to empty space), update the
		# current cell accordingly. And if it happens to be a teleport cell,
		# teleport the runner to the partner cell.

		else:
			if (_curr_cell == null or next_cell == null
				or _curr_cell.get_state() != next_cell.get_state()):
				if next_cell:
					print(Cell.State.keys()[next_cell.get_state()].capitalize())
				else:
					print("Empty")
			if next_cell:
				match next_cell.get_state():
					Cell.State.TELEPORT:
						_check_teleport(next_cell.get_teleport_partner())
					Cell.State.ONE_WAY:
						_check_one_way(next_cell)
			_curr_cell = next_cell

		# Note the current position of the current cell for next time.

		if _curr_cell:
			_curr_cell_pos = _curr_cell.global_position

	$Character/Cam.update_aim_point(global_position)

	# === Animations normales (seulement si pas en action spéciale) ===
	if is_jumping or is_sliding:
		return

	if direction == Vector2.ZERO:
		if last_non_zero_direction == Vector2.ZERO:
			animation_player.play("Intro")
		else:
			if last_non_zero_direction.y < 0:
				animation_player.play("Start_000")
				sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
			else:
				animation_player.play("Start_180")
				sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0
	else:
		if direction.y < 0:
			animation_player.play("Run_000")
			sprite.scale.x = 1.0 if direction.x < 0 else -1.0
		else:
			animation_player.play("Run_180")
			sprite.scale.x = -1.0 if direction.x < 0 else 1.0

# ── FONCTIONS ──
func _play_jump_animation() -> void:
	if last_non_zero_direction == Vector2.ZERO or is_dead or is_falling: return
	is_jumping = true
	jump_direction = last_non_zero_direction
	if last_non_zero_direction.y < 0:
		animation_player.play("Jump_000")
		sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
	else:
		animation_player.play("Jump_180")
		sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0

func _play_slide_animation() -> void:
	if last_non_zero_direction == Vector2.ZERO or is_dead or is_falling: return
	is_sliding = true
	slide_direction = last_non_zero_direction
	if last_non_zero_direction.y < 0:
		animation_player.play("Sliding_000")
		sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
	else:
		animation_player.play("Sliding_180")
		sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


# ── MORT ──
func die() -> void:
	if is_dead: return
	is_dead = true
	direction = Vector2.ZERO
	jump_direction = Vector2.ZERO
	slide_direction = Vector2.ZERO
	is_jumping = false
	is_sliding = false
	is_falling = false
	
	if last_non_zero_direction == Vector2.ZERO:
		animation_player.play("Death_180")
	else:
		if last_non_zero_direction.y < 0:
			animation_player.play("Death_000")
			sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
		else:
			animation_player.play("Death_180")
			sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


# ── CHUTE (nouvelle fonction) ──
func start_falling() -> void:
	if is_falling or is_dead: return
	is_falling = true
	
	# Stoppe net tout mouvement
	direction = Vector2.ZERO
	jump_direction = Vector2.ZERO
	slide_direction = Vector2.ZERO
	is_jumping = false
	is_sliding = false
	
	# Animation de chute avec la bonne orientation
	if last_non_zero_direction == Vector2.ZERO:
		animation_player.play("Falling_180")
	else:
		if last_non_zero_direction.y < 0:
			animation_player.play("Falling_000")
			sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
		else:
			animation_player.play("Falling_180")
			sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("Jump_"):
		is_jumping = false
		jump_direction = Vector2.ZERO
	elif anim_name.begins_with("Sliding_"):
		is_sliding = false
		slide_direction = Vector2.ZERO

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
		if last_non_zero_direction == Vector2.ZERO:
			animation_player.play("Intro")
		elif last_non_zero_direction.y < 0:
			animation_player.play("Start_000")
			sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
		else:
			animation_player.play("Start_180")
			sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


func is_valid_direction(new_direction: Vector2) -> bool:
	if last_direction == Vector2.ZERO:
		return true
	return not is_zero_approx(last_direction.dot(new_direction) + 1.0)

func _check_teleport(destination: Cell):
	if is_teleporting:
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

func _check_one_way(cell: Cell):
	if not collider.overlaps_area(cell.get_one_way_collider()):
		return
	match cell.get_one_way_direction():
		Globals.Axis.NW:
			last_direction = _northwest
		Globals.Axis.NE:
			last_direction = _northeast
		Globals.Axis.SW:
			last_direction = _southwest
		Globals.Axis.SE:
			last_direction = _southeast
	last_non_zero_direction = last_direction
	if _map:
		_map.cancel_one_way(cell)

#
# Methods called by run cycle animation.
#
func play_foot_step_01():
	_footstep1.play()

func play_foot_step_02():
	_footstep2.play()

func play_foot_step_03():
	_footstep3.play()
