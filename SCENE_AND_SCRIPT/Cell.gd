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
	OTHER8,
	OTHER9,
	OTHER10
}

enum State {
	NORMAL,
	LOWERED,
	ARTEFACT,
	HIDDEN,
	TELEPORT,
	ONE_WAY,
	PYLON
}

const width: float = 236.0
const height: float = width * 0.5

@onready var _anim_player: AnimationPlayer = $Global_Cell
@onready var _one_way_directions: Node2D = $Column/Cell_Tops/One_Way_Directions
@onready var _glitch_anim: AnimationPlayer = $Column/Cell_Tops/Top_Cell_FX_Mask/Glitch

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
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_08,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_09,
	$Column/Cell_Tops/Cell_Textures/Cellule_De_Terrain_10
]

var _pylon_scene = preload("res://SCENE_AND_SCRIPT/Pylon.tscn")
var _artefact_scene = preload("res://SCENE_AND_SCRIPT/Artefact.tscn")

var _pylon: Pylon
var _artefact: Artefact
var _state: State = State.NORMAL
var _partner: Cell
var _teleport_type: int

func _ready():
	assert(_textures.size() == Decoration.keys().size())
	for i in _textures.size():
		_textures[i].visible = (i == decoration)

func lower(immediate: bool = false):
	if immediate:
		$Column/Cell_Tops.position.y = 250
		_state = State.LOWERED
	else:
		# the animation will call _set_state_lowered()
		_anim_player.play("Going_Down")
		await _anim_player.animation_finished

func raise():
	# the animation will call _set_state_normal()
	_anim_player.play("Going_Up")
	await _anim_player.animation_finished

#
# Called by the Going_Down animation when the cell has actually begun going
# down.
#
func _set_state_lowered():
	_state = State.LOWERED

#
# Called by the Going_Up animation when the cell is almost back up.
#
func _set_state_normal():
	_state = State.NORMAL

func disappear():
	_anim_player.play("Disappearing")
	await _anim_player.animation_finished
	_state = State.HIDDEN

func reappear():
	_state = State.NORMAL
	_anim_player.play("Appearing")
	await _anim_player.animation_finished

func start_sliding():
	$Sound/Cell_Slide_Sounds/Sliding_Cell.play()
	if _state == State.LOWERED:
		_anim_player.play("Low_Sliding_Beginning")
	else:
		_anim_player.play("High_Sliding_Beginning")

func stop_sliding():
	if _state == State.LOWERED:
		_anim_player.play("Low_Sliding_End")
	else:
		_anim_player.play("High_Sliding_End")
	$Sound/Cell_Slide_Sounds/Sliding_Cell.stop()

func get_sliding_animation_start_length() -> float:
	return _anim_player.get_animation("High_Sliding_Beginning").length

func get_sliding_animation_stop_length() -> float:
	return _anim_player.get_animation("High_Sliding_End").length

func start_one_way(dir: Globals.Axis):
	$Sound/Sound_For_Glitch_Only.play()
	await _one_way_directions.start(dir)
	_state = State.ONE_WAY

func stop_one_way():
	_state = State.NORMAL
	await _one_way_directions.stop()
	$Sound/Sound_For_Glitch_Only.stop()

##
## Turns the cell into a teleport cell. The type parameter chooses between two
## glitch types, and should be 1 or 2. Be sure to call start_teleport() for the
## other teleport cell as well, and to call set_teleport_partner() to associate
## the two cells.
##
func start_teleport(type: int):
	if type == 1:
		$Sound/Sound_For_Glitch_Only.play()
		_glitch_anim.play("Glitch_Only_Appearing")
	else:
		$Sound/Sound_For_Screen_Glitch.play()
		_glitch_anim.play("Screen_Glitch_Appearing")
	await _glitch_anim.animation_finished
	_teleport_type = type
	_state = State.TELEPORT

##
## Turns the teleport cell back into a normal cell. Be sure to call
## stop_teleport() for the other teleport cell as well, and to call
## reset_teleport_partner() to disassociate the two cells.
##
func stop_teleport():
	_state = State.NORMAL
	if _teleport_type == 1:
		_glitch_anim.play("Glitch_Only_Disappearing")
		$Sound/Sound_For_Glitch_Only.stop()
	else:
		_glitch_anim.play("Screen_Glitch_Disappearing")
		$Sound/Sound_For_Screen_Glitch.stop()
	await _glitch_anim.animation_finished

func get_state() -> State:
	return _state

func lower_pylon():
	_add_pylon()
	# _on_pylon_state() is called when the pylon has actually been lowered
	await _pylon.lower()

func raise_pylon():
	# _on_pylon_state() is called when the pylon has actually been raised
	await _pylon.raise()
	_remove_pylon()

func drop_pylon():
	_add_pylon()
	# _on_pylon_state() is called when the pylon has actually been dropped
	await _pylon.drop()

func undrop_pylon():
	# _on_pylon_state() is called when the pylon has actually been raised
	await _pylon.undrop()
	_remove_pylon()

func get_pylon() -> Pylon:
	return _pylon

func _add_pylon():
	if _pylon == null:
		_pylon = _pylon_scene.instantiate()
		_pylon.state_changed.connect(_on_pylon_state_changed)
		add_child(_pylon)

func _remove_pylon():
	if _pylon:
		remove_child(_pylon)
		_pylon.queue_free()
		_pylon = null

func _on_pylon_state_changed(state: Pylon.State):
	_state = State.NORMAL if state == Pylon.State.RAISED else State.PYLON

func add_artefact():
	if _artefact == null:
		_artefact = _artefact_scene.instantiate()
		add_child(_artefact)
		_state = State.ARTEFACT

func remove_artefact():
	if _artefact:
		await _artefact.disappear()
		_state = State.NORMAL
		remove_child(_artefact)
		_artefact.queue_free()
		_artefact = null

##
## Tells a new teleport cell which other cell it teleports to/from. This only
## needs to be called for one of the two cells; it sets the partner cell for
## the other cell as well.
##
func set_teleport_partner(partner: Cell):
	_partner = partner
	partner._partner = self

##
## Resets a teleport cell's "partner" cell when they turn back into normal
## cells. This only needs to be called for one of the two cells; it resets the
## partner cell for both.
##
func reset_teleport_partner():
	if _partner:
		_partner._partner = null
		_partner = null

##
## Returns the cell that this teleport cell teleports to/from.
##
func get_teleport_partner() -> Cell:
	return _partner

##
## For a teleport cell, returns 1 or 2, depending on the parameter that was
## passed to start_teleport().
##
func get_teleport_type() -> int:
	return _teleport_type

func get_one_way_collider() -> Area2D:
	return _one_way_directions.get_collider()

func get_one_way_direction() -> Globals.Axis:
	return _one_way_directions.get_direction()

##
## Returns true if this is the center cell, that is, if decoration is
## Decoration.CENTER.
##
func is_center() -> bool:
	return decoration == Decoration.CENTER

##
## Cofunction that blocks as long as the cell's top is moving.
##
func wait_until_stationary():
	if _anim_player.is_playing():
		await _anim_player.animation_finished

##
## Given the collider from a cell, returns the Cell itself. Returns null if the
## collider does not belong to a cell.
##
static func get_cell_from_collider(collider: Area2D) -> Cell:
	var cell = collider.get_node_or_null("../..")
	return cell if cell is Cell else null

##
## Given that a runner is going to start at the given corner of the map,
## returns the offset with respect to the origin of the cell at that corner
## where the runner should be placed initially. This corresponds to the Marker2D
## nodes found beneath $Column/Cell_Tops/Corner_Start_Points.
##
static func get_start_cell_offset(corner: Globals.Corner) -> Vector2:
	match corner:
		Globals.Corner.N:
			return Vector2(0, -25)
		Globals.Corner.S:
			return Vector2(0, 25)
		Globals.Corner.W:
			return Vector2(-50, 0)
		Globals.Corner.E:
			return Vector2(50, 0)
	return Vector2()
