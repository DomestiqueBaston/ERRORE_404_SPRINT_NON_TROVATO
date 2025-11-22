extends Node2D

@onready var anim_door: AnimationPlayer = $Animation_Door
@onready var anim_door_on: AnimationPlayer = $Animation_Door_On
@onready var hum_sound: AudioStreamPlayer = $Door_Sound/Door_Hum

func _ready() -> void:
	await get_tree().create_timer(randf_range(7.0, 15.0)).timeout
	
	anim_door_on.play("Appearing")
	anim_door.play("Alive")
	hum_sound.play()
