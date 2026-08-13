@tool
class_name Cell extends Node2D

@export var decoration: Decoration = Decoration.OTHER1:
	set(deco):
		if decoration != deco:
			if is_node_ready():
				_textures[decoration].hide()
				_textures[deco].show()
				$Column/Cell_Tops.position.y = -354 if deco == Decoration.CENTER else 0
			decoration = deco
			_is_down = false

enum Decoration {
	CENTER,
	N,
	S,
	W,
	E,
	NW1,
	NW2,
	NW3,
	NE1,
	NE2,
	NE3,
	SW1,
	SW2,
	SW3,
	SE1,
	SE2,
	SE3,
	OTHER1,
	OTHER2,
	OTHER3,
	OTHER4,
	OTHER5,
	OTHER6,
	OTHER7,
	OTHER8
}

@onready var _anim_player: AnimationPlayer = $Global_Cell

@onready var _textures = [
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Centre,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Gauche,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Droit,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Gauche_1,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Gauche_2,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Gauche_3,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Droit_1,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Droit_2,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Haut_Droit_3,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Gauche_1,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Gauche_2,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Gauche_3,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Droit_1,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Droit_2,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_Bord_Bas_Droit_3,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_01,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_02,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_03,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_04,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_05,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_06,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_07,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_08
]

var _pylon_scene = preload("res://SCENE_AND_SCRIPT/Pylon.tscn")
var _pylon: Pylon

var _is_down: bool = false
var _is_busy: bool = false

func _ready():
	assert(_textures.size() == Decoration.keys().size())
	for i in _textures.size():
		_textures[i].visible = (i == decoration)
	$Column/Cell_Tops.position.y = -354 if is_center() else 0

func lower():
	_is_busy = true
	_is_down = true
	if is_center():
		_anim_player.play("404_Going_Down")
	else:
		_anim_player.play("Going_Down")
	await _anim_player.animation_finished
	if is_center():
		_is_busy = false

func raise():
	_anim_player.play("Going_Up")
	await _anim_player.animation_finished
	_is_down = false
	_is_busy = false

func disappear():
	_is_busy = true
	_anim_player.play("Disappearing")
	await _anim_player.animation_finished

func reappear():
	_anim_player.play("Appearing")
	await _anim_player.animation_finished
	_is_busy = false

func start_sliding():
	$Sound/Cell_Slide_Sounds/Sliding_Cell.play()
	if is_center():
		if _is_down:
			_anim_player.play("High_Sliding_Beginning")
		else:
			_anim_player.play("404_High_Sliding_Beginning")
	else:
		if _is_down:
			_anim_player.play("Low_Sliding_Beginning")
		else:
			_anim_player.play("High_Sliding_Beginning")

func stop_sliding():
	if is_center():
		if _is_down:
			_anim_player.play("High_Sliding_End")
		else:
			_anim_player.play("404_High_Sliding_End")
	else:
		if _is_down:
			_anim_player.play("Low_Sliding_End")
		else:
			_anim_player.play("High_Sliding_End")
	$Sound/Cell_Slide_Sounds/Sliding_Cell.stop()

func get_sliding_animation_start_length() -> float:
	return _anim_player.get_animation("High_Sliding_Beginning").length

func get_sliding_animation_stop_length() -> float:
	return _anim_player.get_animation("High_Sliding_End").length

func start_one_way(dir: Globals.Axis):
	_is_busy = true
	$Sound/Sound_For_Glitch_Only.play()
	$Column/Cell_Tops/One_Way_Direction.set_direction(dir)
	$Column/Cell_Tops/One_Way_Direction/Direction_Animation.play("Appearing")

func stop_one_way():
	$Column/Cell_Tops/One_Way_Direction/Direction_Animation.play("Disappearing")
	$Sound/Sound_For_Glitch_Only.stop()
	await $Column/Cell_Tops/One_Way_Direction/Direction_Animation.animation_finished
	_is_busy = false

func start_bug1():
	_is_busy = true
	$Sound/Sound_For_Glitch_Only.play()
	$Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.play("Glitch_Only_Appearing")

func stop_bug1():
	$Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.play("Glitch_Only_Disappearing")
	$Sound/Sound_For_Glitch_Only.stop()
	await $Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.animation_finished
	_is_busy = false

func start_bug2():
	_is_busy = true
	$Sound/Sound_For_Screen_Glitch.play()
	$Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.play("Screen_Glitch_Appearing")

func stop_bug2():
	$Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.play("Screen_Glitch_Disappearing")
	$Sound/Sound_For_Screen_Glitch.stop()
	await $Column/Cell_Tops/Top_Cell_FX_Mask/Glitch.animation_finished
	_is_busy = false

func add_pylon() -> Pylon:
	if _pylon:
		return null
	_pylon = _pylon_scene.instantiate()
	add_child(_pylon)
	return _pylon

func remove_pylon():
	if _pylon:
		remove_child(_pylon)
		_pylon.queue_free()
		_pylon = null

func get_pylon() -> Pylon:
	return _pylon

##
## Returns true if this is the center cell, that is, if decoration is
## Decoration.CENTER.
##
func is_center() -> bool:
	return decoration == Decoration.CENTER

##
## Returns true if the cell has been lowered and not yet raised, hidden and not
## yet unhidden, etc.
##
func is_busy() -> bool:
	return _is_busy or _pylon
