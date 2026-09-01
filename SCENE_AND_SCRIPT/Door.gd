extends Node2D

func _ready():
	# Z indexes are relative to the parent cell's
	$Door_Shadow.z_index = Globals.DOOR_BACK_Z_OFFSET
	$Door_Back.z_index = Globals.DOOR_BACK_Z_OFFSET
	$Door_Front.z_index = Globals.DOOR_FRONT_Z_OFFSET
