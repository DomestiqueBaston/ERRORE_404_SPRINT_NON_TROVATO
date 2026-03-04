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
	master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(0))
	music_slider.value = _db_to_slider_music(AudioServer.get_bus_volume_db(3))

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
		UISounds.play_menu_navigation()

	elif Input.is_action_just_pressed("ui_down_button"):
		selected_slider += 1
		if selected_slider > 3:
			selected_slider = 0
		_update_slider_visuals()
		UISounds.play_menu_navigation()
	
	if Input.is_action_just_pressed("ui_right_button"):
		if !is_slider_at_max(selected_slider):
			adjust_slider_value(1)
			UISounds.play_woosh()

	elif Input.is_action_just_pressed("ui_left_button"):
		if !is_slider_at_min(selected_slider):
			adjust_slider_value(-1)
			UISounds.play_woosh()

func is_slider_at_min(slider_index: int) -> bool:
	var slider: HSlider = get_slider_by_index(slider_index)
	return slider.value <= slider.min_value
	
func is_slider_at_max(slider_index: int) -> bool:
	var slider: HSlider = get_slider_by_index(slider_index)
	return slider.value >= slider.max_value
	
func get_slider_by_index(index: int) -> HSlider:
	match index:
		0: return map_slider
		1: return difficulty_slider
		2: return master_slider
		3: return music_slider
	return null

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
			$Masks/Map/Settings_Gradients/Map_Color.show()
			$Map.text = " • Dimensione della mappa • "
			$Masks/Map.text = " • Dimensione della mappa • "
		1:
			$Masks/Difficulty/Settings_Gradients/Difficulty_Color.show()
			$Difficulty.text = " • Difficoltà • "
			$Masks/Difficulty.text = " • Difficoltà • "
		2:
			$Masks/Audio/Settings_Gradients/Audio_Color.show()
			$Audio.text = " • Livello audio generale • "
			$Masks/Audio.text = " • Livello audio generale • "
		3:
			$Masks/Music/Settings_Gradients/Music_Color.show()
			$Music.text = " • Livello della musica • "
			$Masks/Music.text = " • Livello della musica • "
			
	_reset_texts_if_deselected()
	
func _reset_texts_if_deselected():
	if selected_slider != 0:
		$Masks/Map/Settings_Gradients/Map_Color.hide()
		$Map.text = default_map_text
		$Masks/Map.text = default_map_text
	if selected_slider != 1:
		$Masks/Difficulty/Settings_Gradients/Difficulty_Color.hide()
		$Difficulty.text = default_difficulty_text
		$Masks/Difficulty.text = default_difficulty_text
	if selected_slider != 2:
		$Masks/Audio/Settings_Gradients/Audio_Color.hide()
		$Audio.text = default_audio_text
		$Masks/Audio.text = default_audio_text
	if selected_slider != 3:
		$Masks/Music/Settings_Gradients/Music_Color.hide()
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
	return lerp(-10.0, 0.0, normalized)

func _db_to_slider(db: float) -> float:
	var normalized = (db + 10.0) / 10.0
	return normalized * 100.0

func _slider_to_db_music(value: float) -> float:
	var max_music = -7.5
	var normalized = value / 100.0
	return lerp(-15.0, max_music, normalized)

func _db_to_slider_music(db: float) -> float:
	var normalized = (db + 15.0) / 7.5
	return normalized * 100.0


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
