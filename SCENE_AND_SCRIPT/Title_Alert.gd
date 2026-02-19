extends Control

@onready var animation_player: AnimationPlayer = $Animation_Overlay
@export var blink_timeout: float = 10.0

var initial_delay_done: bool = false


func _ready() -> void:
	self.hide()
	$"../Glitches".show()
	$"../BackBufferCopy_Reflection".show()
	
	await get_tree().create_timer(blink_timeout).timeout
	
	initial_delay_done = true
	self.show()
	animation_player.play("Blink")


func _process(_delta: float) -> void:
	var quit_visible = $"../../Quit_Button/Progress_Bar".visible
	
	if quit_visible:
		if animation_player.is_playing():
			animation_player.stop()
		self.hide()
	
	else:
		if initial_delay_done and not animation_player.is_playing():
			self.show()
			animation_player.play("Blink")
