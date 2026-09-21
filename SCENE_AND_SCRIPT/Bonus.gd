@tool
class_name Bonus extends RefCounted

## Bonus represents a bonus/malus picked up by a runner when he comes upon a
## cube. Usually it activates automatically (is_automatic() returns true), but
## some must be activated explicitly by the runner.

enum Type {
	INVINCIBLE,
	DASH,
	THROUGH,
	VIRUS,
	AUTO_DODGE,
	DEBUG,
	WALL_BREAKER,
	INVERT,
	SLOW,
	WALL_EXTENDER,
	ANTI_DASH,
	PHASE,
	ANTI_VIRUS,
	NO_TURN
}

var type: Type

# bonus/malus types that are NOT activated automatically
var _delayed_types = [Type.DASH, Type.AUTO_DODGE, Type.DEBUG]

##
## Returns true if this bonus/malus is activated as soon as the player grabs it,
## false if he has to activate it himself.
##
func is_automatic() -> bool:
	return not type in _delayed_types

##
## Returns how long (in seconds) the bonus/malus expires after activation. A
## value of zero means it takes effect and then expires immediately; a negative
## value means it must be removed explicitly, i.e. once it has been used.
##
func get_duration() -> float:
	match type:
		Type.INVINCIBLE:
			return 6 - Globals.difficulty
		Type.DASH:
			return 0.5
		Type.THROUGH:
			return -1
		Type.VIRUS:
			return 10 - Globals.difficulty
		Type.AUTO_DODGE:
			return 6 - Globals.difficulty
		Type.DEBUG:
			return 10 - Globals.difficulty
		Type.WALL_BREAKER:
			return 0
		Type.INVERT:
			return Globals.difficulty
		Type.SLOW:
			return 2 * Globals.difficulty
		Type.WALL_EXTENDER:
			return 1.5 * Wall.get_duration()
		Type.ANTI_DASH:
			return 3 + 2 * Globals.difficulty
		Type.PHASE:
			return 2 * Globals.difficulty
		Type.ANTI_VIRUS:
			return 10 - Globals.difficulty
		Type.NO_TURN:
			return 0.5 + 0.5 * Globals.difficulty
		_:
			return -1

static func pick_random_type() -> Type:
	return (randi() % Type.keys().size()) as Type
