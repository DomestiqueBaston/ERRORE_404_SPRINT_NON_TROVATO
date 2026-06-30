extends Control

@onready var anim: AnimationPlayer = $Animation_Text

var has_played := false

func _ready():
	anim.animation_finished.connect(_on_anim_finished)
	if is_visible_in_tree():
		play_once()

func play_once():
	if has_played:
		return
	has_played = true
	anim.play("Writing")

func _notification(what):
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if is_visible_in_tree():
			play_once()

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == "Writing":
		anim.play("Final_Blink")
