class_name EnemyParty
extends RefCounted
## A group of enemies that wander in the same direction and attack the player all at once.

var id := -1                    # number of the party in the save file
var members: Array = []         # the Enemy nodes of this party
var _direction := Vector2.ZERO  # shared wander direction
var _next_change := 0           # time (ms) when a new direction is picked


## The shared wander direction. A new random one is picked every `delay` seconds, by whoever asks first.
func wander_direction(delay: float) -> Vector2:
	var now := Time.get_ticks_msec()
	if _direction == Vector2.ZERO or now >= _next_change:
		_direction = Vector2.from_angle(randf() * TAU)
		_next_change = now + int(delay * 1000.0)
	return _direction


## True if at least one living member still has the player inside its detection area.
func anyone_sees() -> bool:
	for m in members:
		if is_instance_valid(m) and m.health > 0 and m.sees_target:
			return true
	return false
