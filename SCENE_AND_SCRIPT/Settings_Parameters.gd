extends Control

@export var master_db_min: float = -10.0
@export var master_db_max: float = 0.0

@export var music_db_min: float = -15.0
@export var music_db_max: float = -7.5

var _master_db_init: float
var _music_db_init: float
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
var _is_updating: bool = false

func _ready():
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

func update():
	var use_diagonals = Globals.use_diagonals_for_movement
	$Directions/Diagonals.visible = use_diagonals
	$Directions/Cardinals.visible = not use_diagonals
	$Masks/Diagonals.visible = use_diagonals
	$Masks/Cardinals.visible = not use_diagonals

	map_slider.value = 2 * Globals.map_size + 1

	difficulty_slider.max_value = Globals.max_difficulty
	difficulty_slider.tick_count = Globals.max_difficulty
	difficulty_slider.value = Globals.difficulty
	$Difficulty_1_5.visible = Globals.max_difficulty <= 5
	$Masks/Difficulty_1_5.visible = Globals.max_difficulty <= 5
	$Difficulty_1_6.visible = Globals.max_difficulty > 5
	$Masks/Difficulty_1_6.visible = Globals.max_difficulty > 5

	_master_db_init = AudioServer.get_bus_volume_db(Globals.master_bus)
	_music_db_init = AudioServer.get_bus_volume_db(Globals.music_bus)

	_is_updating = true
	master_slider.value = _db_to_slider_master(_master_db_init)
	music_slider.value = _db_to_slider_music(_music_db_init)
	_is_updating = false

	_update_slider_visuals()

func reset():
	AudioServer.set_bus_volume_db(Globals.master_bus, _master_db_init)
	AudioServer.set_bus_volume_db(Globals.music_bus, _music_db_init)

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

func _slider_to_db_master(value: float) -> float:
	return lerp(master_db_min, master_db_max, value / 100.0)

func _db_to_slider_master(db: float) -> float:
	return 100.0 * ((db - master_db_min) / (master_db_max - master_db_min))

func _slider_to_db_music(value: float) -> float:
	return lerp(music_db_min, music_db_max, value / 100.0)

func _db_to_slider_music(db: float) -> float:
	return 100.0 * ((db - music_db_min) / (music_db_max - music_db_min))

func _on_master_slider_changed(value: float):
	if not _is_updating:
		AudioServer.set_bus_volume_db(Globals.master_bus, _slider_to_db_master(value))

func _on_music_slider_changed(value: float):
	if not _is_updating:
		AudioServer.set_bus_volume_db(Globals.music_bus, _slider_to_db_music(value))

func get_use_diagonals() -> bool:
	return $Directions/Diagonals.visible

func get_map_size() -> int:
	return ((map_slider.value - 1) / 2) as int

func get_difficulty() -> int:
	return difficulty_slider.value as int
