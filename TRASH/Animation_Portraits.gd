extends AnimationPlayer

## Ce script (comme pas mal d'autres)
## ne sert que de démo pour les effets !

@onready var animation_player : AnimationPlayer = $"."
var delay_min : float = 4.0
var delay_max : float = 8.0
var current_anim_state : String = "Her_To_Him"

func get_random_delay() -> float:
	return randf_range(delay_min, delay_max)


func play_next_animation():
	if current_anim_state == "Her_To_Him":
		animation_player.play("Her_To_Him")
		current_anim_state = "Him_To_Her"
	else:
		animation_player.play("Him_To_Her")
		current_anim_state = "Her_To_Him"


func _ready():
	randomize()
	
	_start_animation_cycle()

func _start_animation_cycle():
	play_next_animation()
	
	await get_tree().create_timer(get_random_delay()).timeout
	_start_animation_cycle()
