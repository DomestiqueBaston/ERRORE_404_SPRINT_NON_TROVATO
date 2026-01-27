extends Control


func _ready():
	if is_visible_in_tree():
		$Glitches/Sound_Animation.play("Glitchy_Sound")
