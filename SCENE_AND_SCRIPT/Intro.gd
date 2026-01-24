extends AudioStreamPlayer

func _ready():
	AudioServer.set_bus_volume_db(3, -60)
	play()

	var tween = create_tween()
	tween.tween_method(
		Callable(self, "_on_tween_update"),
		-60,  # Valeur initiale
		-6,    # Valeur finale
		5.0   # Durée en secondes
	)

func _on_tween_update(new_volume: float) -> void:
	AudioServer.set_bus_volume_db(3, new_volume)
