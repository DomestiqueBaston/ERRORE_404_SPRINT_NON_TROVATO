extends TextureProgressBar

@export var hold_to_show_time := 0.25
@export var fill_duration := 0.75

var _press_timer := 0.0
var _fill_timer := 0.0
var _locked := false
var charge_completed : bool = false

func _ready():
	visible = false
	value = min_value

func _process(delta):
	if Input.is_action_pressed("ui_quit_button"):
		_press_timer += delta
		
		if _press_timer >= hold_to_show_time:
			visible = true
			
			if not _locked and not charge_completed:
				_fill_timer += delta
				value = lerp(min_value, max_value, _fill_timer / fill_duration)
				
				if _fill_timer >= fill_duration:
					_locked = true
					value = max_value
					charge_completed = true
					_on_charge_completed()
	
	else:
		if not _locked:
			visible = false
			value = min_value
			_fill_timer = 0.0
		
		_press_timer = 0.0

func _on_charge_completed():
	UISounds.play_full()
	await get_tree().create_timer(0.666).timeout
	get_tree().quit()
