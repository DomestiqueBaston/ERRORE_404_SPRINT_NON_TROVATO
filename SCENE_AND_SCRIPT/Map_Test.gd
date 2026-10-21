extends Node2D

enum Character {
	WOMAN_A,
	WOMAN_B,
	MAN_A,
	MAN_B
}

@export var character: Character = Character.WOMAN_A
@export var start_corner: Globals.Corner
@export var is_bot: bool = false

const START_ACTIONS := [
	"ui_a_button",
	"ui_b_button",
	"ui_x_button",
	"ui_y_button",
	"ui_left_button",
	"ui_right_button",
	"ui_up_button",
	"ui_down_button",
]

@onready var _map_scene = preload("res://SCENE_AND_SCRIPT/Map.tscn")

var _once := true
var _can_restart := false
var _bot: Bot

func _ready():
	var map = _map_scene.instantiate()
	map.map_size = Globals.map_size
	add_child(map)

	var scene: PackedScene
	match character:
		Character.WOMAN_A:
			scene = load("res://SCENE_AND_SCRIPT/Woman_A.tscn")
		Character.WOMAN_B:
			scene = load("res://SCENE_AND_SCRIPT/Woman_B.tscn")
		Character.MAN_A:
			scene = load("res://SCENE_AND_SCRIPT/Man_A.tscn")
		Character.MAN_B:
			scene = load("res://SCENE_AND_SCRIPT/Man_B.tscn")

	var runner = scene.instantiate()
	runner.set_environment(map, start_corner, $Camera)
	add_child(runner)

	if is_bot:
		_bot = Bot.new(runner, map, start_corner)
		add_child(_bot)

	map.start()
	runner.start()

func _unhandled_input(event: InputEvent) -> void:
	# Détection de la première action du joueur
	for action in START_ACTIONS:
		if event.is_action_pressed(action):
			_can_restart = true
			if _once:
				Sounds.stop_intro()
				Sounds.play_music()
				if _bot:
					_bot.start()
				_once = false
			break

	# Redémarrage de la scène (pour test)
	if _can_restart and event.is_action_pressed("ui_tab_button"):
		Sounds.stop_all()
		Sounds.play_bang()
		Sounds.play_intro()
		get_tree().reload_current_scene()
