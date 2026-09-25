extends Node2D

enum Character {
	WOMAN_A,
	WOMAN_B,
	MAN_A,
	MAN_B
}

@export var character: Character = Character.WOMAN_A
@export var start_corner: Globals.Corner

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

var _map: Map
var _once := true
var _can_restart := false

func _ready():
	var sz: int = Globals.map_size
	_map = _map_scene.instantiate()
	_map.map_size = sz
	add_child(_map)

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

	var start_cell: Cell
	match start_corner:
		Globals.Corner.N:
			start_cell = _map.get_cell_at(Vector2i(-sz, sz))
		Globals.Corner.S:
			start_cell = _map.get_cell_at(Vector2i(sz, -sz))
		Globals.Corner.W:
			start_cell = _map.get_cell_at(Vector2i(-sz, -sz))
		Globals.Corner.E:
			start_cell = _map.get_cell_at(Vector2i(sz, sz))
	var start_pos = start_cell.position + Cell.get_start_cell_offset(start_corner)

	var runner = scene.instantiate()
	runner.position = start_pos
	runner.set_map(_map, start_cell)

	var camera = Camera2D.new()
	camera.process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	add_child(camera)

	var remote_xform = RemoteTransform2D.new()
	remote_xform.remote_path = camera.get_path()
	runner.add_child(remote_xform)

	runner.offset_camera.connect(
		func(offset: Vector2):
			create_tween().set_trans(Tween.TRANS_CUBIC).tween_property(
				camera, ^"offset", offset, 0.75))

	add_child(runner)

func _unhandled_input(event: InputEvent) -> void:
	# Détection de la première action du joueur
	for action in START_ACTIONS:
		if event.is_action_pressed(action):
			_can_restart = true
			if _once:
				Sounds.stop_intro()
				Sounds.play_music()
				_once = false
			break

	# Redémarrage de la scène (pour test)
	if _can_restart and event.is_action_pressed("ui_tab_button"):
		Sounds.stop_all()
		Sounds.play_bang()
		Sounds.play_intro()
		get_tree().reload_current_scene()
