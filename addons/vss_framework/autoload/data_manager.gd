extends Node
## Central registry for all data-driven definitions.
##
## Characters, weapons, accessories, enemies and stages are described by
## [Resource]-based data classes and registered here by string id. Gameplay code
## looks definitions up through this singleton rather than hardcoding values.

var characters: Dictionary = {}
var weapons: Dictionary = {}
var accessories: Dictionary = {}
var enemies: Dictionary = {}
var stages: Dictionary = {}


func register_character(data: CharacterData) -> void:
	characters[data.id] = data


func register_weapon(data: WeaponData) -> void:
	weapons[data.id] = data


func register_accessory(data: AccessoryData) -> void:
	accessories[data.id] = data


func register_enemy(data: EnemyData) -> void:
	enemies[data.id] = data


func register_stage(data: StageData) -> void:
	stages[data.id] = data


func get_character(id: String) -> CharacterData:
	return characters.get(id)


func get_weapon(id: String) -> WeaponData:
	return weapons.get(id)


func get_accessory(id: String) -> AccessoryData:
	return accessories.get(id)


func get_enemy(id: String) -> EnemyData:
	return enemies.get(id)


func get_stage(id: String) -> StageData:
	return stages.get(id)


## Returns every registered weapon id.
func weapon_ids() -> Array:
	return weapons.keys()


## Returns every registered accessory id.
func accessory_ids() -> Array:
	return accessories.keys()
