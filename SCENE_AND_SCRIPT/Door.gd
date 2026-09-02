class_name Door extends Node2D

enum HitArea {
	NONE,
	DOOR,
	PASSAGE
}

#
# This contains, for each runner's collider, an array of 3 booleans indicating
# whether the collider intersects with each of the 3 collision shapes under
# Collider_Door. The Door script tracks this itself in order to simplify the
# code for runners (because the Door's collider contains 3 different shapes).
# For that to work, Collider_Door must be Monitoring, and runners' colliders
# must be Monitorable.
#
var _collider_shapes_overlap_per_runner: Dictionary

func _ready():
	# Z indexes are relative to the parent cell's
	$Door_Shadow.z_index = Globals.DOOR_BACK_Z_OFFSET
	$Door_Back.z_index = Globals.DOOR_BACK_Z_OFFSET
	$Door_Front.z_index = Globals.DOOR_FRONT_Z_OFFSET

	# track runners' colliders entering and exiting the door's collider
	var collider: Area2D = $Collider_Door
	collider.area_shape_entered.connect(_on_area_shape_entered)
	collider.area_shape_exited.connect(_on_area_shape_exited)

func _on_area_shape_entered(
	_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int):
	var overlaps = _get_shape_overlaps_for(area)
	overlaps[local_shape_index] = true

func _on_area_shape_exited(
	_area_rid: RID, area: Area2D, _area_shape_index: int, local_shape_index: int):
	var overlaps = _get_shape_overlaps_for(area)
	overlaps[local_shape_index] = false

##
## Tests the given Area2D for overlap with the door's colliders. Returns:
## - HitArea.DOOR if it overlaps with either side of the door frame,
## - HitArea.PASSAGE if it overlaps with the passageway through the middle, or
## - HitArea.NONE otherwise.
##
func get_overlap(area: Area2D) -> HitArea:
	var overlaps = _get_shape_overlaps_for(area)
	if overlaps[1] or overlaps[2]:
		return HitArea.DOOR
	elif overlaps[0]:
		return HitArea.PASSAGE
	else:
		return HitArea.NONE

#
# Returns an array of 3 booleans for the given collider (which presumably
# belongs to a runner), creating the array if necessary.
#
func _get_shape_overlaps_for(area: Area2D) -> Array[bool]:
	var overlaps: Array[bool]
	if _collider_shapes_overlap_per_runner.has(area):
		overlaps = _collider_shapes_overlap_per_runner[area]
	else:
		overlaps.resize(3)
		_collider_shapes_overlap_per_runner[area] = overlaps
	return overlaps
