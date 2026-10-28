class_name Portraits extends Control

@onready var _arrow_anim: AnimationPlayer = $Animation_Arrows
@onready var _player_anim: AnimationPlayer = $Animation_Portraits

var _current_index: int = 0
var _candidates: Array[int] = [0, 1, 2, 3]
var _is_animating: bool = false

##
## Starts the portrait animation and calls set_character_index().
##
func start(char_index: int = 0):
	_arrow_anim.play(&"Blink")
	set_character_index(char_index)

##
## Stops the portrait animation.
##
func stop():
	_arrow_anim.stop()

##
## Selects the given character, where char_index is an index into
## Globals.runner_scene_names.
##
func set_character_index(char_index: int):
	if _current_index != char_index:
		_current_index = char_index
		_player_anim.play(Globals.runner_scene_names[char_index] + "_From_Left")

##
## Returns the index of the currently selected character (an index into
## Globals.runner_scene_names).
##
func get_character_index() -> int:
	return _current_index

##
## Removes the given character from the pool of available characters. Do not
## disable the character that is currently selected!
##
func disable_character(char_index: int):
	_candidates.erase(char_index)

##
## Scrolls to the next available character, in one direction or the other (incr
## should be -1 or 1). Returns false if the portraits are still scrolling after
## a previous call, or if there are no other characters available.
##
func scroll(incr: int) -> bool:
	if _is_animating or _candidates.size() <= 1:
		return false

	_is_animating = true

	var char_count = Globals.runner_scene_names.size()
	var old_index = _current_index
	var new_index = posmod(_current_index + incr, char_count)
	while not new_index in _candidates:
		new_index = posmod(new_index + incr, char_count)
	var old_char = Globals.runner_scene_names[old_index]
	var new_char = Globals.runner_scene_names[new_index]

	old_char += "_To_Right" if incr > 0 else "_To_Left"
	new_char += "_From_Left" if incr > 0 else "_From_Right"

	await _play_sequence(old_char, new_char)

	_is_animating = false
	_current_index = new_index
	return true

func _play_sequence(anim_out: StringName, anim_in: StringName):
	if _player_anim.has_animation(anim_out):
		_player_anim.play(anim_out)
		await _player_anim.animation_finished
	else:
		print("Animation missing:", anim_out)

	if _player_anim.has_animation(anim_in):
		_player_anim.play(anim_in)
		await _player_anim.animation_finished
	else:
		print("Animation missing:", anim_in)
