extends AudioStreamPlayer

func _ready():
	var music_player = $"../Music"
	var bang_player = $"../Bang"

	if not music_player.playing:
		bang_player.play()
		play()
