class_name Pylon extends Node2D

enum State {
	RAISED,
	LOWERED,
	DROPPED
}

var _state: State = State.RAISED

func lower():
	Sounds.play_pylon_down()
	await get_tree().create_timer(0.5).timeout
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
	await get_tree().create_timer(0.25).timeout
	$Pylon_Animation.play("Going_Down_Falling")
	await $Pylon_Animation.animation_finished
	_state = State.DROPPED

func undrop():
	_state = State.RAISED
	$Pylon_Animation.play("Going_Up_Falling")
	await $Pylon_Animation.animation_finished

func get_state() -> State:
	return _state
