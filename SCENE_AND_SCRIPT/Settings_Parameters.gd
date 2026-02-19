extends Control

@onready var map_slider = $HSlider_Map
@onready var difficulty_slider = $HSlider_Difficulty
@onready var master_slider = $HSlider_Audio
@onready var music_slider = $HSlider_Music

# Important : le son max. pour le bus MUSIC, c'est -7.5db (pour le moment) !

var map_start_value : float
var difficulty_start_value : float
var master_start_value : float
var music_start_value : float

var selected_slider = 0

var sliders: Array[HSlider]

var normal_grabbers := {}
var highlight_grabbers := {}

var default_map_text = "   Dimensione della mappa   "
var default_difficulty_text = "   Difficoltà   "
var default_audio_text = "   Livello audio generale   "
var default_music_text = "   Livello della musica   "

func _ready():
	map_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	difficulty_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	master_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	music_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	map_start_value = map_slider.value
	difficulty_start_value = difficulty_slider.value
	master_start_value = master_slider.value
	music_start_value = music_slider.value

	map_slider.value_changed.connect(_on_map_slider_changed)
	difficulty_slider.value_changed.connect(_on_difficulty_slider_changed)
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)

	sliders = [map_slider, difficulty_slider, master_slider, music_slider]

	# Stockage des icônes normales / highlight
	for slider in sliders:
		normal_grabbers[slider] = slider.get_theme_icon("grabber")
		highlight_grabbers[slider] = slider.get_theme_icon("grabber_highlight")

	_update_slider_visuals()


func _process(_delta):

	if Input.is_action_just_pressed("ui_up_button"):
		selected_slider -= 1
		if selected_slider < 0:
			selected_slider = 3
		_update_slider_visuals()

	elif Input.is_action_just_pressed("ui_down_button"):
		selected_slider += 1
		if selected_slider > 3:
			selected_slider = 0
		_update_slider_visuals()
	
	if Input.is_action_just_pressed("ui_right_button"):
		adjust_slider_value(1)
	elif Input.is_action_just_pressed("ui_left_button"):
		adjust_slider_value(-1)


func _update_slider_visuals():
	for i in sliders.size():
		var slider = sliders[i]
		
		if i == selected_slider:
			slider.add_theme_icon_override(
				"grabber",
				highlight_grabbers[slider]
			)
		else:
			slider.add_theme_icon_override(
				"grabber",
				normal_grabbers[slider]
			)
	match selected_slider:
		0:
			$Map.text = " • Dimensione della mappa • "
			$Masks/Map.text = " • Dimensione della mappa • "
		1:
			$Difficulty.text = " • Difficoltà • "
			$Masks/Difficulty.text = " • Difficoltà • "
		2:
			$Audio.text = " • Livello audio generale • "
			$Masks/Audio.text = " • Livello audio generale • "
		3:
			$Music.text = " • Livello della musica • "
			$Masks/Music.text = " • Livello della musica • "
			
	_reset_texts_if_deselected()
	
func _reset_texts_if_deselected():
	if selected_slider != 0:
		$Map.text = default_map_text
		$Masks/Map.text = default_map_text
	if selected_slider != 1:
		$Difficulty.text = default_difficulty_text
		$Masks/Difficulty.text = default_difficulty_text
	if selected_slider != 2:
		$Audio.text = default_audio_text
		$Masks/Audio.text = default_audio_text
	if selected_slider != 3:
		$Music.text = default_music_text
		$Masks/Music.text = default_music_text


func adjust_slider_value(direction: int):
	var slider: HSlider = null
	
	match selected_slider:
		0:
			slider = map_slider
		1:
			slider = difficulty_slider
		2:
			slider = master_slider
		3:
			slider = music_slider

	if slider:
		var new_value = slider.value + direction * slider.step
		new_value = clamp(new_value, slider.min_value, slider.max_value)
		slider.value = new_value
		
		if selected_slider == 0:
			_on_map_slider_changed(new_value)
		elif selected_slider == 1:
			_on_difficulty_slider_changed(new_value)
		elif selected_slider == 2:
			_on_master_slider_changed(new_value)
		elif selected_slider == 3:
			_on_music_slider_changed(new_value)


func _slider_to_db(value: float) -> float:
	var normalized = value / 100.0
	return lerp(-80.0, 0.0, pow(normalized, 0.1))


func _db_to_slider(db: float) -> float:
	var normalized = (db + 80.0) / 80.0
	return pow(normalized, 5) * 100.0


func _slider_to_db_music(value: float) -> float:
	# Important : le son max. pour le bus MUSIC, c'est -7.5db (pour le moment) !
	var max_music = -7.5
	var normalized = value / 100.0
	return lerp(-80.0, max_music, pow(normalized, 0.1))


func _db_to_slider_music(db: float) -> float:
	var normalized = (db + 80.0) / 70.0
	return pow(normalized, 5) * 100.0


func _on_map_slider_changed(_value: float):
	pass


func _on_difficulty_slider_changed(_value: float):
	pass


func _on_master_slider_changed(value: float):
	var db = _slider_to_db(value)
	AudioServer.set_bus_volume_db(0, db)


func _on_music_slider_changed(value: float):
	var db = _slider_to_db_music(value)
	AudioServer.set_bus_volume_db(3, db)
