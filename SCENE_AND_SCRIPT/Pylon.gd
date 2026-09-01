class_name Pylon extends Node2D

enum State {
	RAISED,
	LOWERED,
	DROPPED
}

signal state_changed(state: State)

var _state: State = State.RAISED

func _ready():
	# Z index is relative to the parent cell's
	z_index = Globals.PYLON_Z_OFFSET

func lower():
	Sounds.play_pylon_down()
	await get_tree().create_timer(0.75).timeout
	$Pylon_Animation.play("Going_Down")
	await $Pylon_Animation.animation_finished
	Sounds.stop_pylon_down()
	_state = State.LOWERED

func raise():
	_state = State.RAISED
	$Pylon_Animation.play("Going_Up")
	await $Pylon_Animation.animation_finished

func drop():
	Sounds.play_pylon_crunch()
	await get_tree().create_timer(0.333).timeout
	$Pylon_Animation.play("Going_Down_Falling")
	await $Pylon_Animation.animation_finished
	_state = State.DROPPED

func undrop():
	_state = State.RAISED
	$Pylon_Animation.play("Going_Up_Falling")
	await $Pylon_Animation.animation_finished

func get_state() -> State:
	return _state

#
# Called by animations when the lowered or dropped pylon has been raised again.
#
func _set_raised_state():
	_state = State.RAISED
	state_changed.emit(_state)

#
# Called by the Going_Down animation when the pylon has actually been lowered.
#
func _set_lowered_state():
	_state = State.LOWERED
	state_changed.emit(_state)

#
# Called by the Going_Down_Falling animation when the pylon has actually been
# dropped.
#
func _set_dropped_state():
	_state = State.DROPPED
	state_changed.emit(_state)
