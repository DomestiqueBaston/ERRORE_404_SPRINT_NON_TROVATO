@tool
class_name Bonus extends RefCounted

## Bonus represents a bonus/malus picked up by a runner when he comes upon a
## cube.

enum Type {
	INVINCIBLE,
	DASH,
	PIERCE_WALLS,
	VIRUS,
	AUTO_DODGE,
	DEBUG,
	VANISH_WALLS,
	# VANISH_WALLS is the last bonus, INVERT is the first malus: see is_bonus()
	INVERT,
	SLOW,
	EXTEND_WALLS,
	ANTI_DASH,
	PHASE,
	ANTI_VIRUS,
	NO_TURN
}

var type: Type

##
## Returns true for a bonus, false for a malus.
##
func is_bonus() -> bool:
	return type <= Type.VANISH_WALLS

##
## Returns how long (in seconds) the bonus/malus expires after activation. A
## value of zero means it expires immediately once it has been used.
##
func get_duration() -> float:
	match type:
		Type.INVINCIBLE:
			return 11 - Globals.difficulty
		Type.DASH:
			return 8 - Globals.difficulty
		Type.PIERCE_WALLS:
			return 8 - Globals.difficulty
		Type.VIRUS:
			return 11 - Globals.difficulty
		Type.AUTO_DODGE:
			return 8 - Globals.difficulty
		Type.DEBUG:
			return 11 - Globals.difficulty
		Type.VANISH_WALLS:
			return 0
		Type.INVERT:
			return Globals.difficulty
		Type.SLOW:
			return 3 * Globals.difficulty
		Type.EXTEND_WALLS:
			return 1.5 * Wall.get_duration()
		Type.ANTI_DASH:
			return 3 + 2 * Globals.difficulty
		Type.PHASE:
			return 10 + 2 * Globals.difficulty
		Type.ANTI_VIRUS:
			return 10 - Globals.difficulty
		Type.NO_TURN:
			return Globals.difficulty
		_:
			return 0

##
## Returns the color associated with the bonus/malus.
##
func get_color() -> Color:
	return get_type_color(type)

##
## Returns the color associated with the bonus/malus type.
##
static func get_type_color(t: Type) -> Color:
	match t:
		Type.INVINCIBLE, Type.INVERT:
			return Color.RED
		Type.DASH, Type.ANTI_DASH:
			return Color.GREEN
		Type.PIERCE_WALLS, Type.PHASE:
			return Color.BLUE
		Type.VIRUS, Type.ANTI_VIRUS:
			return Color.PURPLE
		Type.AUTO_DODGE, Type.NO_TURN:
			return Color.YELLOW
		Type.DEBUG, Type.SLOW:
			return Color.GRAY
		Type.VANISH_WALLS, Type.EXTEND_WALLS:
			return Color.WHITE
		_:
			return Color.BLACK
