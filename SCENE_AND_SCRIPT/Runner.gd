extends Node2D

@onready var sprite: Sprite2D = $Runner_Sprite
@onready var animation_player: AnimationPlayer = $"../Animation_Runner"
@export var move_speed: float = 350.0

var direction: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.ZERO
var last_non_zero_direction: Vector2 = Vector2.ZERO # Stocke la dernière direction non nulle

func _process(delta):
	var input_direction = Vector2.ZERO
	if Input.is_action_just_pressed("ui_cancel"):
		last_direction = Vector2.ZERO
	
	## Je ne suis absolument pas certain que 18.4 et -18.4 soient les valeurs parfaites (à l'oeil on dirait).##
	## Il faudra vérifier sur de grandes distances, il est possible qu'il y ait un décalage par rapport au sol.##
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
	
	direction = last_direction
	velocity = direction * move_speed
	position += velocity * delta

	if direction == Vector2.ZERO:
		if last_non_zero_direction == Vector2.ZERO: # Aucune direction enregistrée
			animation_player.play("Intro")
		else:
			if last_non_zero_direction.y < 0: # Haut-gauche ou haut-droit
				animation_player.play("Start_000")
				sprite.scale.x = 1.0 if last_non_zero_direction.x < 0 else -1.0
			else: # Bas-gauche ou bas-droit
				animation_player.play("Start_180")
				sprite.scale.x = -1.0 if last_non_zero_direction.x < 0 else 1.0
	elif direction.x < 0 and direction.y < 0: # Diagonale haut-gauche
		animation_player.play("Run_000")
		sprite.scale.x = 1.0
	elif direction.x > 0 and direction.y < 0: # Diagonale haut-droit
		animation_player.play("Run_000")
		sprite.scale.x = -1.0
	elif direction.x < 0 and direction.y > 0: # Diagonale bas-gauche
		animation_player.play("Run_180")
		sprite.scale.x = -1.0
	elif direction.x > 0 and direction.y > 0: # Diagonale bas-droit
		animation_player.play("Run_180")
		sprite.scale.x = 1.0

func is_valid_direction(new_direction: Vector2) -> bool:
	if last_direction == Vector2.ZERO:
		return true
	var dot_product = last_direction.dot(new_direction)
	if abs(dot_product + 1.0) < 0.0001:
		return false
	return true
