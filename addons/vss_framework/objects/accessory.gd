class_name Accessory
extends Equipment
## Base class for all passive accessories.
##
## An accessory grants stats to its owner. The owner recomputes its effective
## stats whenever an accessory is added or levelled, reading the result of
## [method get_current_stats].

var accessory_data: AccessoryData


## Initialises the accessory. Called by [method CharacterController.add_accessory].
func setup(new_owner: CharacterController, data: AccessoryData) -> void:
	owner = new_owner
	accessory_data = data
	level = 1


func is_max_level() -> bool:
	return level >= accessory_data.max_level


func level_up() -> bool:
	if is_max_level():
		return false
	level += 1
	return true


func display_name() -> String:
	return accessory_data.display_name


## Returns the stats this accessory currently grants (base + per-level bonus).
func get_current_stats() -> ModifierStats:
	var s := accessory_data.stats.scaled(1.0)
	s.add(accessory_data.level_bonus.scaled(float(level - 1)))
	return s
