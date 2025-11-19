extends Node2D

@onready var sprite: Sprite2D = $Runner_Sprite
@onready var animation_player: AnimationPlayer = $"../Animation_Runner"

@export var move_speed: float = 400.0 # 350 pour ne pas patiner mais c'est un peu lent !
@export var jump_speed: float = 350.0
@export var slide_speed: float = 300.0

var direction: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var last_non_zero_direction: Vector2 = Vector2.ZERO

# États
var is_jumping: bool = false
var is_sliding: bool = false

# Directions figées
var jump_direction: Vector2 = Vector2.ZERO
var slide_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)


func _process(delta: float) -> void:
	var input_direction := Vector2.ZERO

	# Reset total avec Échap
	if Input.is_action_just_pressed("ui_cancel"):
		last_direction = Vector2.ZERO
		# last_non_zero_direction = Vector2.ZERO   # ← SUPPRIMÉ → c'était le bug !
		jump_direction = Vector2.ZERO
		slide_direction = Vector2.ZERO
		direction = Vector2.ZERO

		# On force immédiatement l'animation idle orientée correcte
		if last_non_zero_direction == Vector2.ZERO:
			animation_player.play("Intro")
		elif last_non_zero_direction.y < 0:
			animation_player.play("Start_000")
			sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
		else:
			animation_player.play("Start_180")
			sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0

		return  # on sort du _process pour ce frame (évite les conflits)

	# SAUT (A)
	if Input.is_action_just_pressed("ui_a_button") and not is_jumping and not is_sliding:
		_play_jump_animation()

	# SLIDE (B)
	if Input.is_action_just_pressed("ui_b_button") and not is_jumping and not is_sliding:
		_play_slide_animation()

	# === Entrées de déplacement (seulement hors saut/slide) ===
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

	# === Calcul du mouvement avec vitesse dynamique ===
	var current_speed: float = move_speed

	if is_jumping:
		direction = jump_direction
	elif is_sliding:
		direction = slide_direction
	else:
		direction = last_direction

	# Gestion du lerp de vitesse (une seule fois, proprement)
	var anim := animation_player.current_animation
	if anim.begins_with("Jump_"):
		var progress := animation_player.current_animation_position / animation_player.current_animation_length
		current_speed = lerp(move_speed, jump_speed, progress)
	elif anim.begins_with("Sliding_"):
		# Ralentissement progressif pendant toute l'animation Sliding
		var progress := animation_player.current_animation_position / animation_player.current_animation_length
		# Lerp de move_speed → slide_speed
		current_speed = lerp(move_speed, slide_speed, progress)
	else:
		# Quand on n'est plus dans une animation spéciale → vitesse cible finale
		if is_jumping:
			current_speed = jump_speed
		elif is_sliding:
			current_speed = slide_speed
		# sinon c'est déjà move_speed

	position += direction * current_speed * delta

	# === Gestion des animations ===
	if is_jumping or is_sliding:
		return

	# Idle ou course normale
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


func _play_jump_animation() -> void:
	if last_non_zero_direction == Vector2.ZERO:
		return
	is_jumping = true
	jump_direction = last_non_zero_direction
	if last_non_zero_direction.y < 0:
		animation_player.play("Jump_000")
		sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
	else:
		animation_player.play("Jump_180")
		sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


func _play_slide_animation() -> void:
	if last_non_zero_direction == Vector2.ZERO:
		return
	is_sliding = true
	slide_direction = last_non_zero_direction
	if last_non_zero_direction.y < 0:
		animation_player.play("Sliding_000")
		sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
	else:
		animation_player.play("Sliding_180")
		sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0


func _on_animation_finished(anim_name: String) -> void:
	if anim_name.begins_with("Jump_"):
		is_jumping = false
		jump_direction = Vector2.ZERO
	elif anim_name.begins_with("Sliding_"):
		is_sliding = false
		slide_direction = Vector2.ZERO

	# Retour à course/idle
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
