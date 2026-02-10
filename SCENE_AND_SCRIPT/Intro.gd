extends AudioStreamPlayer

func _ready():
	var music_player = $"../Music"
	var bang_player = $"../Bang"
	var global_hum = $"../Global_Hum"

	if not music_player.playing:
		bang_player.play()
		play()
	else: 
		global_hum.play()
