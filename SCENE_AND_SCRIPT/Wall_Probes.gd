extends Node2D

## Defines colliders (Area2D instances) that extent in every direction in which
## the runner may move. They can be used to test for the presence of walls
## blocking the runner's path in each direction.

@onready var _colliders: Dictionary[Globals.Axis, Area2D] = {
	Globals.Axis.NW: $NW,
	Globals.Axis.NE: $NE,
	Globals.Axis.SW: $SW,
	Globals.Axis.SE: $SE
}

##
## Enables the colliders (turns on their monitoring property). By default, the
## colliders are disabled.
##
func set_enabled(enabled: bool):
	for collider: Area2D in _colliders.values():
		collider.monitoring = enabled
		collider.visible = enabled

##
## Checks for walls blocking the path in the given direction (which is assumed
## to be one of the four directions in which runners can move). If any are
## found, returns the distance to the nearest wall in "cell" units (the length
## of the side of a cell). If not, INF is returned.
##
## Note that this will only work if set_enabled(true) has been called.
##
func check_for_walls(dir: Vector2) -> float:
	var collider: Area2D = _colliders[Globals.dir_to_axis(dir)]
	var collisions: Array[Area2D] = collider.get_overlapping_areas()
	if collisions:
		var dist2 = INF
		for area in collisions:
			var wall = Wall.get_wall_from_collider(area)
			if wall:
				var pt = Geometry2D.get_closest_point_to_segment(
					global_position, wall.get_start_point(), wall.get_end_point())
				dist2 = minf(dist2, global_position.distance_squared_to(pt))
		return sqrt(dist2) / Cell.side_length
	return INF
