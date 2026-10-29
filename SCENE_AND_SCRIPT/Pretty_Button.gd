class_name PrettyButton extends Control

## PrettyButton is a pretty button containing a TextureProgressBar, which
## appears when the user keeps an action event pressed for a given amount of
## time, and disappears when he releases the action.
##
## You must call start() for the PrettyButton to start handling input events,
## and stop() to turn the button off and stop handling input events.

## Name of the input action that triggers the button when pressed.
@export var button_action: StringName = &"ui_quit_button"

## Optional pause after the action is pressed and before the button appears.
@export var initial_press_duration: float = 0.25

## How much longer the action must be pressed for the progress bar to reach the
## end.
@export var fill_duration: float = 0.666

## Optional pause after the progress bar has reached the end and before emitting
## the done() signal.
@export var pause_duration: float = 0.333

## Signal emitted when the button's progress bar is shown or hidden.
signal button_toggled(toggled: bool)

## Signal emitted in the end to trigger whatever event is going to be triggered.
signal done

@onready var _progress = $Progress_Bar
@onready var _timer = $Timer

var _tween: Tween
var _done: bool = false

func _ready():
	_reset()
	_timer.timeout.connect(_on_timeout)
	set_process_input(false)

func _reset():
	_timer.stop()
	if _tween:
		_tween.stop()
		_tween = null
	if _progress.visible:
		_progress.hide()
		button_toggled.emit(false)
	_progress.value = _progress.min_value

##
## Starts listening for the input action that activates the button.
##
func start():
	set_process_input(true)

##
## Resets the button and stops listening for the input action that activates it.
##
func stop():
	set_process_input(false)
	_reset()

func _input(event: InputEvent):
	if _done:
		return
	if event.is_action_pressed(button_action):
		_reset()
		if initial_press_duration > 0:
			_timer.start(initial_press_duration)
		else:
			_on_timeout()
	elif event.is_action_released(button_action):
		_reset()

#
# Called on a timer timeout, meaning either that the button has been pressed
# for initial_press_duration and it is time to start loading the progress bar
# (_done is false), or that the progress bar has finished loading and
# pause_duration has elapsed (_done is true).
#
func _on_timeout():
	if _done:
		done.emit()
	else:
		_progress.show()
		button_toggled.emit(true)
		_tween = create_tween()
		_tween.tween_property(_progress, "value", _progress.max_value, fill_duration)
		_tween.finished.connect(_on_completed)

#
# Called when the progress bar has finished loading: after another pause, the
# done() signal is emitted.
#
func _on_completed():
	Sounds.play_full()
	_done = true
	if pause_duration > 0:
		_timer.start(pause_duration)
	else:
		_on_timeout()
