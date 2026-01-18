extends Control

@onready var animation_player = $Animation_Overlay

func _ready():
	$".".hide()
	await get_tree().create_timer(10.0).timeout
	$".".show()
	animation_player.play("Blink")
