extends Control

@onready var master_slider = $HSlider_Audio
@onready var music_slider = $HSlider_Music

func _ready():
	# Important : le son max. pour la musique, c'est -7.5db (pour le moment) !
	var master_db = AudioServer.get_bus_volume_db(0)
	master_slider.value = _db_to_slider(master_db)
	master_slider.value_changed.connect(_on_master_slider_changed)
	
	var music_db = AudioServer.get_bus_volume_db(3)
	music_slider.value = _db_to_slider_music(music_db)
	music_slider.value_changed.connect(_on_music_slider_changed)

func _slider_to_db(value: float) -> float:
	var normalized = value / 100.0
	return lerp(-80.0, 0.0, pow(normalized, 0.1))

func _db_to_slider(db: float) -> float:
	var normalized = (db + 80.0) / 80.0
	return pow(normalized, 5) * 100.0

func _slider_to_db_music(value: float) -> float:
	# Important : le son max. pour la musique, c'est -7.5db (pour le moment) !
	var max_music = -7.5
	var normalized = value / 100.0
	return lerp(-80.0, max_music, pow(normalized, 0.1))

func _db_to_slider_music(db: float) -> float:
	var normalized = (db + 80.0) / 70.0
	return pow(normalized, 5) * 100.0

func _on_master_slider_changed(value: float):
	var db = _slider_to_db(value)
	AudioServer.set_bus_volume_db(0, db)
	#print("Volume master réglé à ", db, " dB (slider: ", value, ")")

func _on_music_slider_changed(value: float):
	var db = _slider_to_db_music(value)
	AudioServer.set_bus_volume_db(3, db)
	print("Volume musique réglé à ", db, " dB (slider: ", value, ")")

	var current_music_db = AudioServer.get_bus_volume_db(3)
	print("Volume actuel du bus musique (4) : ", current_music_db, " dB")
