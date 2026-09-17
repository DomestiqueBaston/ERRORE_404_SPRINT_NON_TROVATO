class_name Door extends CellAttachment

##
## Cell zones returned by get_zone_at().
##
enum Zone {
	FRAME,
	PASSAGE,
	BACK,
	MIDDLE,
	FRONT
}

##
## Constants for depth ordering (Z-index). The two sides of the door are
## displayed at depth BACK_DOOR and FRONT_DOOR; a runner can position himself
## behind both doors (BACK), in front of both (FRONT) or inbetween (MIDDLE).
##
enum Depth {
	BACK,
	BACK_DOOR,
	MIDDLE,
	FRONT_DOOR,
	FRONT
}

@onready var _frame_left: Area2D = $Leg_G
@onready var _frame_right: Area2D = $Leg_D
@onready var _passage: Area2D = $Door
@onready var _back: Area2D = $Leg_G_Faces
@onready var _front: Area2D = $Leg_D_Faces
@onready var _middle: Area2D = $Door_Faces

func _ready():
	$Door_Back.z_index = Depth.BACK_DOOR
	$Door_Front.z_index = Depth.FRONT_DOOR

func get_zone_at(collider: Area2D) -> Zone:
	var zones = collider.get_overlapping_areas()
	for zone in zones:
		if zone.get_parent() == self:
			match zone:
				_frame_left, _frame_right:
					return Zone.FRAME
				_passage:
					return Zone.PASSAGE
				_back:
					return Zone.BACK
				_middle:
					return Zone.MIDDLE
				_front:
					return Zone.FRONT
	return Zone.MIDDLE
