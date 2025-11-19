extends Node2D

@onready var anim_on_off: AnimationPlayer = $Animation_Cube_On_Off
@onready var anim_alive:  AnimationPlayer = $Animation_Cube

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_timeout)
	
	anim_on_off.animation_finished.connect(_on_on_off_finished)
	
	await get_tree().create_timer(randf_range(3.0, 5.0)).timeout
	_show_cube()


func _show_cube() -> void:
	anim_on_off.play("Appearing")
	anim_alive.play("Alive")
	
	_timer_start()


func _hide_cube() -> void:
	anim_on_off.play("Disappearing")

func _on_on_off_finished(anim_name: String) -> void:
	if anim_name == "Appearing":
		pass
	
	elif anim_name == "Disappearing" or anim_name == "Disappering":
		anim_alive.stop()
		
		_timer_start()


func _on_timer_timeout() -> void:
	if anim_on_off.current_animation == "Appearing" or anim_alive.is_playing():
		_hide_cube()
	else:
		_show_cube()
		
func _timer_start() -> void:
	timer.start(randf_range(5.0, 15.0))
