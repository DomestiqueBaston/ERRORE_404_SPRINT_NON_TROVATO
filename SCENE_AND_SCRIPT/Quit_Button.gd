class_name QuitButton extends PrettyButton

func _ready():
	super._ready()
	done.connect(_on_quit)
	start()

func _on_quit():
	get_tree().quit()
