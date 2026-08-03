@tool
class_name Cell extends Node2D

@export var decoration: Decoration = Decoration.OTHER1:
	set(deco):
		if decoration != deco:
			if is_node_ready():
				_textures[decoration].hide()
				_textures[deco].show()
			decoration = deco

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

var _is_down: bool = false

func _ready():
	assert(_textures.size() == Decoration.keys().size())
	for i in _textures.size():
		_textures[i].visible = (i == decoration)

func lower():
	_is_down = true
	$Global_Cell.play("Going_Down")

func raise():
	$Global_Cell.play("Going_Up")
	await $Global_Cell.animation_finished
	_is_down = false

func start_sliding():
	if _is_down:
		$Global_Cell.play("Low_Sliding_Beginning")
	else:
		$Global_Cell.play("High_Sliding_Beginning")

func stop_sliding():
	if _is_down:
		$Global_Cell.play("Low_Sliding_End")
	else:
		$Global_Cell.play("High_Sliding_End")
