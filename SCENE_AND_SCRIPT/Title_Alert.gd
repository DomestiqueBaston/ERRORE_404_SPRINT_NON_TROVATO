extends Control


##############################################################################
## Lorsque Quit_Button sera actif, il faudra stopper et cacher Info_Overlay ##
##############################################################################

@onready var animation_player = $Animation_Overlay
@export var blink_timeout: float = 10.0


func _ready():
	self.hide()
	$"../Glitches".show()
	$"../BackBufferCopy_Reflection".show()
	await get_tree().create_timer(blink_timeout).timeout
	self.show()
	animation_player.play("Blink")
	

func _process(_delta):
	if $"../../Quit_Button/Progress_Bar".visible:
		self.hide()
		animation_player.playback_active = false
	else:
		animation_player.playback_active = true
		self.show()
