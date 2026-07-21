extends Control

# Important : le son max. pour le bus MUSIC, c'est -7.5db (pour le moment) !

var _selected_slider: int = 0

var _slider_text: Array[String] = [
	"Vettori direzionali:                    ",
	"Dimensione della mappa",
	"Difficoltà",
	"Livello audio generale",
	"Livello della musica"
]

@onready var _slider_labels: Array[RichTextLabel] = [
	$Directions,
	$Map,
	$Difficulty,
	$Audio,
	$Music
]

@onready var _slider_masks: Array[RichTextLabel] = [
	$Masks/Directions,
	$Masks/Map,
	$Masks/Difficulty,
	$Masks/Audio,
	$Masks/Music
]

@onready var _slider_highlights: Array[ColorRect] = [
	$Masks/Directions/Settings_Gradients/Map_Color,
	$Masks/Map/Settings_Gradients/Map_Color,
	$Masks/Difficulty/Settings_Gradients/Difficulty_Color,
	$Masks/Audio/Settings_Gradients/Audio_Color,
	$Masks/Music/Settings_Gradients/Music_Color
]

@onready var map_slider: HSlider = $HSlider_Map
@onready var difficulty_slider: HSlider = $HSlider_Difficulty
@onready var master_slider: HSlider = $HSlider_Audio
@onready var music_slider: HSlider = $HSlider_Music

@onready var _hsliders: Array[HSlider] = [
	null,
	map_slider,
	difficulty_slider,
	master_slider,
	music_slider
]

var _normal_grabbers: Array[Texture2D]
var _highlight_grabbers: Array[Texture2D]

func _ready():
	var use_diagonals = Globals.use_diagonals_for_movement
	$Directions/Diagonals.visible = use_diagonals
	$Directions/Cardinals.visible = not use_diagonals
	$Masks/Diagonals.visible = use_diagonals
	$Masks/Cardinals.visible = not use_diagonals

	master_slider.value = _db_to_slider(AudioServer.get_bus_volume_db(0))
	music_slider.value = _db_to_slider_music(AudioServer.get_bus_volume_db(3))

	map_slider.value_changed.connect(_on_map_slider_changed)
	difficulty_slider.value_changed.connect(_on_difficulty_slider_changed)
	master_slider.value_changed.connect(_on_master_slider_changed)
	music_slider.value_changed.connect(_on_music_slider_changed)

	for i in _hsliders.size():
		var slider: HSlider = _hsliders[i]
		if slider:
			slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
			_normal_grabbers.append(slider.get_theme_icon("grabber"))
			_highlight_grabbers.append(slider.get_theme_icon("grabber_highlight"))
		else:
			_normal_grabbers.append(null)
			_highlight_grabbers.append(null)

	_update_slider_visuals()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_up_button"):
		_selected_slider -= 1
		if _selected_slider < 0:
			_selected_slider = 4
		_update_slider_visuals()
		Sounds.play_menu_navigation()
	elif event.is_action_pressed("ui_down_button"):
		_selected_slider += 1
		if _selected_slider > 4:
			_selected_slider = 0
		_update_slider_visuals()
		Sounds.play_menu_navigation()
	elif event.is_action_pressed("ui_right_button"):
		if _selected_slider == 0 or !_is_slider_at_max(_selected_slider):
			_adjust_slider_value(1)
			Sounds.play_woosh()
	elif event.is_action_pressed("ui_left_button"):
		if _selected_slider == 0 or !_is_slider_at_min(_selected_slider):
			_adjust_slider_value(-1)
			Sounds.play_woosh()

func _is_slider_at_min(_index:int) -> bool:
	var slider: HSlider = _hsliders[_selected_slider]
	return slider and slider.value <= slider.min_value

func _is_slider_at_max(_index:int) -> bool:
	var slider: HSlider = _hsliders[_selected_slider]
	return slider and slider.value >= slider.max_value

func _update_slider_visuals():
	var dot = " • "
	var nodot = "   "
	for i in _slider_text.size():
		var slider: HSlider = _hsliders[i]
		if _selected_slider == i:
			if slider:
				slider.add_theme_icon_override("grabber", _highlight_grabbers[i])
			_slider_highlights[i].show()
			_slider_labels[i].text = dot + _slider_text[i] + dot
		else:
			if slider:
				slider.add_theme_icon_override("grabber", _normal_grabbers[i])
			_slider_highlights[i].hide()
			_slider_labels[i].text = nodot + _slider_text[i] + nodot
		_slider_masks[i].text = _slider_labels[i].text

func _adjust_slider_value(direction: int):
	if _selected_slider == 0:
		$Directions/Diagonals.visible = !$Directions/Diagonals.visible
		$Directions/Cardinals.visible = !$Directions/Cardinals.visible
		$Masks/Diagonals.visible = !$Masks/Diagonals.visible
		$Masks/Cardinals.visible = !$Masks/Cardinals.visible
	else:
		var slider: HSlider = _hsliders[_selected_slider]
		var new_value = slider.value + direction * slider.step
		new_value = clamp(new_value, slider.min_value, slider.max_value)
		slider.value = new_value

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
	AudioServer.set_bus_volume_db(0, _slider_to_db(value))

func _on_music_slider_changed(value: float):
	AudioServer.set_bus_volume_db(3, _slider_to_db_music(value))

func get_use_diagonals() -> bool:
	return $Directions/Diagonals.visible
