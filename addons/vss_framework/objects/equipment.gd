class_name Equipment
extends RefCounted
## Base class for everything a character can hold: [Weapon]s and [Accessory]s.
##
## Equipment is a plain object (not a [Node]); the owning [CharacterController]
## drives it by calling [method update] every frame and owns its lifetime.

## The character that owns this piece of equipment.
var owner: CharacterController = null

## Current level of this equipment (starts at 1).
var level: int = 1


## Returns true when this equipment has reached its maximum level.
func is_max_level() -> bool:
	return false


## Attempts to level this equipment up. Returns true on success.
func level_up() -> bool:
	return false


## Called every frame by the owner while the run is active.
func update(_delta: float) -> void:
	pass


## Human-readable name shown in the level-up screen.
func display_name() -> String:
	return ""
