extends Control

@export var initial_press_duration := 0.25
@export var fill_duration := 0.75
@export var pause_duration := 0.666

## Signal emitted when the progress bar is shown or hidden.
signal quit_button_toggled(toggled: bool)

@onready var _progress = $Progress_Bar
@onready var _timer = $Timer

var _tween: Tween
var _done: bool = false

func _ready():
	_reset()
	_timer.timeout.connect(_on_timeout)

func _reset():
	if _tween:
		_tween.stop()
		_tween = null
	if _progress.visible:
		_progress.hide()
		quit_button_toggled.emit(false)
	_progress.value = _progress.min_value

func _input(event: InputEvent):
	if _done:
		return
	if event.is_action_pressed("ui_quit_button"):
		_reset()
		_timer.start(initial_press_duration)
	elif event.is_action_released("ui_quit_button"):
		_timer.stop()
		_reset()

#
# Called on a timer timeout, meaning either that the button has been pressed
# for initial_press_duration and it is time to start loading the progress bar
# (_done is false), or that the progress bar has finished loading and
# pause_duration has elapsed (_done is true).
#
func _on_timeout():
	if _done:
		get_tree().quit()
	else:
		_progress.show()
		quit_button_toggled.emit(true)
		_tween = create_tween()
		_tween.tween_property(_progress, "value", _progress.max_value, fill_duration)
		_tween.finished.connect(_on_completed)

#
# Called when the progress bar has finished loading: quit after pause_duration.
#
func _on_completed():
	Sounds.play_full()
	_done = true
	_timer.start(pause_duration)
