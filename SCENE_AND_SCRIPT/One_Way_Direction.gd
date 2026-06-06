extends Node2D

# Ce script ne sert à rien d'autre que donner les orientations des noeuds
# en fonction de l'orientation voulue de la flèche.

@onready var shadow_orientation: Node2D = $Shadow_Orientation
@onready var direction_orientation: Node2D = $Direction_Orientation

@export var direction: Vector2 = Vector2(1, 1)

@export var south_east: bool = false
@export var south_west: bool = false
@export var north_east: bool = false
@export var north_west: bool = false

func _ready() -> void:
	if south_east:
		$Shadow_Orientation.scale = Vector2(1.0, 1.0)
		$Direction_Orientation.scale = Vector2(1.0, 1.0)
		$Direction_Orientation.position = Vector2(-9.0, -55.0)
	if north_west:
		$Shadow_Orientation.scale = Vector2(-1.0, -1.0)
		$Direction_Orientation.scale = Vector2(-1.0, -1.0)
		$Direction_Orientation.position = Vector2(11.0, -45.0)
	if south_west:
		$Shadow_Orientation.scale = Vector2(-1.0, 1.0)
		$Direction_Orientation.scale = Vector2(-1.0, 1.0)
		$Direction_Orientation.position = Vector2(11.0, -55.0)
	if north_east:
		$Shadow_Orientation.scale = Vector2(1.0, -1.0)
		$Direction_Orientation.scale = Vector2(1.0, -1.0)
		$Direction_Orientation.position = Vector2(-9.0, -45.0)
		
