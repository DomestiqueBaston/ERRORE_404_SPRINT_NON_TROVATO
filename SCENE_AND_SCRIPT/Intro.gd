extends AudioStreamPlayer

func _ready():
	var default_volume = AudioServer.get_bus_volume_db(3)
	var music_player = $"../Music"
	
	if not music_player.playing:
		AudioServer.set_bus_volume_db(3, -60)
		play()
		print("Intro playing")
		
		var tween = create_tween()
		tween.tween_method(
			Callable(self, "_on_tween_update"),
			-60,
			default_volume,
			5.0
		)
	else:

		print("Music is already playing. No changes to volume.")
		
func _on_tween_update(new_volume: float) -> void:

	AudioServer.set_bus_volume_db(3, new_volume)
