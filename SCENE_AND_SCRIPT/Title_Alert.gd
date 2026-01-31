extends Control

@onready var animation_player = $Animation_Overlay
@export var blink_timeout: float = 10.0

func _ready():
	$".".hide()
	$"../Glitches".show()
	$"../BackBufferCopy_Reflection".show()
	await get_tree().create_timer(blink_timeout).timeout
	$".".show()
	animation_player.play("Blink")
