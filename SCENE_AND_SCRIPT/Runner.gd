extends Node2D

## La Vision_Area n'est pas gérée par ce script vu que là,
## c'est juste de la démo...

@onready var sprite: Node2D = $Papa_Sprite
@onready var animation_player: AnimationPlayer = $"../Animation_Runner"

@export var move_speed: float = 375.0
@export var jump_speed: float = 350.0
@export var slide_speed: float = 300.0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var last_non_zero_direction: Vector2 = Vector2.ZERO

# États
var is_jumping: bool = false
var is_sliding: bool = false
var is_dead: bool = false
var is_falling: bool = false

# Directions figées
var jump_direction: Vector2 = Vector2.ZERO
var slide_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)

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

	# Reset total avec Échap
	if Input.is_action_just_pressed("ui_cancel"):
		last_direction = Vector2.ZERO
		jump_direction = Vector2.ZERO
		slide_direction = Vector2.ZERO
		direction = Vector2.ZERO
		if last_non_zero_direction == Vector2.ZERO:
			animation_player.play("Intro")
		elif last_non_zero_direction.y < 0:
			animation_player.play("Start_000")
			sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
		else:
			animation_player.play("Start_180")
			sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0
		return

	# SAUT (A)
	if Input.is_action_just_pressed("ui_a_button") and not is_jumping and not is_sliding:
		_play_jump_animation()

	# SLIDE (B)
	if Input.is_action_just_pressed("ui_b_button") and not is_jumping and not is_sliding:
		_play_slide_animation()

	# === Entrées de déplacement ===
	if not is_jumping and not is_sliding:
		if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_down"):
			input_direction = Vector2(1, 1).rotated(deg_to_rad(-18.4))
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_down"):
			input_direction = Vector2(-1, 1).rotated(deg_to_rad(18.4))
		elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_up"):
			input_direction = Vector2(1, -1).rotated(deg_to_rad(18.4))
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_up"):
			input_direction = Vector2(-1, -1).rotated(deg_to_rad(-18.4))

		if input_direction != Vector2.ZERO:
			if is_valid_direction(input_direction.normalized()):
				last_direction = input_direction.normalized()
				last_non_zero_direction = last_direction

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
	if not is_dead and not is_falling:
		position += direction * current_speed * delta

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


#########################################################
## Fonctions des Call Method Tracks (Animation_Runner) ##
#########################################################
func play_foot_step_01():
	$"../Sound/Foot_Step_01".play()
	
func play_foot_step_02():
	$"../Sound/Foot_Step_02".play()
	
func play_foot_step_03():
	$"../Sound/Foot_Step_03".play()
