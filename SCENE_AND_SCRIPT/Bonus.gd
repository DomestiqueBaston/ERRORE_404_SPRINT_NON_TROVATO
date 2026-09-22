@tool
class_name Bonus extends RefCounted

## Bonus represents a bonus/malus picked up by a runner when he comes upon a
## cube. Usually it activates automatically (is_automatic() returns true), but
## some must be activated explicitly by the runner.

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
var is_activated: bool = false

##
## Returns true for a bonus, false for a malus.
##
func is_bonus() -> bool:
	return type <= Type.VANISH_WALLS

##
## Returns true if this bonus/malus is activated as soon as the player grabs it,
## false if he has to activate it himself. For now, at least, all bonuses must
## be activated, and all maluses are automatic.
##
func is_automatic() -> bool:
	return not is_bonus()

##
## Returns how long (in seconds) the bonus/malus expires after activation. A
## value of zero means it expires immediately once it has been used.
##
func get_duration() -> float:
	match type:
		Type.INVINCIBLE:
			return 10 - Globals.difficulty
		Type.DASH:
			return 6 - Globals.difficulty
		Type.PIERCE_WALLS:
			return 6 - Globals.difficulty
		Type.VIRUS:
			return 10 - Globals.difficulty
		Type.AUTO_DODGE:
			return 6 - Globals.difficulty
		Type.DEBUG:
			return 10 - Globals.difficulty
		Type.VANISH_WALLS:
			return 0
		Type.INVERT:
			return Globals.difficulty
		Type.SLOW:
			return 2 * Globals.difficulty
		Type.EXTEND_WALLS:
			return 1.5 * Wall.get_duration()
		Type.ANTI_DASH:
			return 3 + 2 * Globals.difficulty
		Type.PHASE:
			return 3 * Globals.difficulty
		Type.ANTI_VIRUS:
			return 10 - Globals.difficulty
		Type.NO_TURN:
			return Globals.difficulty
		_:
			return 0

static func pick_random_type() -> Type:
	return (randi() % Type.keys().size()) as Type
