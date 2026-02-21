extends Node

@onready var anim_player: AnimationPlayer = $Animation_Portraits

var characters := [
	"Woman_A",
	"Man_A",
	"Woman_B",
    "Man_B"
]

var current_index: int = 0
var is_animating: bool = false


func _ready():
	self.visible = false
	current_index = 0
	self.visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if self.visible:
		$Animation_Arrows.play("Blink")
	else:
		$Animation_Arrows.stop()

func _unhandled_input(event: InputEvent) -> void:
	if not self.visible or is_animating:
		return

	if event.is_action_pressed("ui_right_button"):
		select_right()

	elif event.is_action_pressed("ui_left_button"):
		select_left()


func select_right():
	if is_animating:
		return

	is_animating = true

	var old_index = current_index
	var new_index = (current_index + 1) % characters.size()
	current_index = new_index

	var old_char = characters[old_index]
	var new_char = characters[new_index]

	await play_sequence(
		old_char + "_To_Right",
		new_char + "_From_Left"
	)

	is_animating = false


func select_left():
	if is_animating:
		return

	is_animating = true

	var old_index = current_index
	var new_index = (current_index - 1 + characters.size()) % characters.size()
	current_index = new_index

	var old_char = characters[old_index]
	var new_char = characters[new_index]

	await play_sequence(
		old_char + "_To_Left",
		new_char + "_From_Right"
	)

	is_animating = false


func play_sequence(anim_out: String, anim_in: String) -> void:
	if anim_player.has_animation(anim_out):
		anim_player.play(anim_out)
		await anim_player.animation_finished
	else:
		print("Animation manquante:", anim_out)

	if anim_player.has_animation(anim_in):
		anim_player.play(anim_in)
		await anim_player.animation_finished
	else:
		print("Animation manquante:", anim_in)
