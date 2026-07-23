extends Control

@onready var animation_player: AnimationPlayer = $Animation_Overlay

##
## Makes the Control visible and starts the Blink animation.
##
func show_overlay():
	show()
	animation_player.play("Blink")

##
## Makes the Control invisible and stops the Blink animation.
##
func hide_overlay():
	hide()
	animation_player.stop()
