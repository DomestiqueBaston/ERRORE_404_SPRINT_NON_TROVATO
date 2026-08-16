extends Sprite2D

func _ready() -> void:
	if material:
		material = material.duplicate()
