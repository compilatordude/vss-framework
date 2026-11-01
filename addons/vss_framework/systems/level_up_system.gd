class_name LevelUpSystem
extends Node
## Generates and applies level-up choices.
##
## When the player levels up it pauses the game, builds a set of random choices
## (new/upgraded weapons and accessories, plus flat stat boosts) and emits
## [signal SignalBus.level_up_choices_ready]. The level-up screen presents them
## and calls [method apply_choice].

const CHOICE_COUNT := 3
const MAX_WEAPONS := 6
const MAX_ACCESSORIES := 6

## Flat stat boosts that can always appear as a level-up choice.
const STAT_BOOSTS: Array[Dictionary] = [
	{"stat": "power", "value": 0.10, "label": "Might", "desc": "+10% damage"},
	{"stat": "cooldown", "value": 0.08, "label": "Haste", "desc": "-8% weapon cooldown"},
	{"stat": "area", "value": 0.10, "label": "Reach", "desc": "+10% area"},
	{"stat": "move_speed", "value": 15.0, "label": "Swiftness", "desc": "+15 move speed"},
	{"stat": "max_hp", "value": 20.0, "label": "Vitality", "desc": "+20 max health"},
	{"stat": "magnet", "value": 20.0, "label": "Attraction", "desc": "+20 pickup range"},
	{"stat": "regen", "value": 0.2, "label": "Regeneration", "desc": "+0.2 health/s"},
	{"stat": "armor", "value": 1.0, "label": "Toughness", "desc": "+1 armor"},
]


func _ready() -> void:
	SignalBus.player_leveled_up.connect(_on_player_leveled_up)


func _on_player_leveled_up(_new_level: int) -> void:
	var choices := _generate_choices()
	if choices.is_empty():
		GameManager.player.finish_level_up()
		return
	GameManager.pause()
	SignalBus.level_up_choices_ready.emit(choices)


# -- Choice generation -------------------------------------------------------

func _generate_choices() -> Array:
	var player := GameManager.player
	var pool: Array = []

	for weapon in player.weapons:
		if not weapon.is_max_level():
			pool.append(_make_upgrade_weapon_choice(weapon))
	for accessory in player.accessories:
		if not accessory.is_max_level():
			pool.append(_make_upgrade_accessory_choice(accessory))

	if player.weapons.size() < MAX_WEAPONS:
		for id in DataManager.weapon_ids():
			if player.find_weapon(id) == null:
				pool.append(_make_new_weapon_choice(DataManager.get_weapon(id)))
	if player.accessories.size() < MAX_ACCESSORIES:
		for id in DataManager.accessory_ids():
			if player.find_accessory(id) == null:
				pool.append(_make_new_accessory_choice(DataManager.get_accessory(id)))

	for boost in STAT_BOOSTS:
		pool.append(_make_stat_choice(boost))

	pool.shuffle()
	return pool.slice(0, mini(CHOICE_COUNT, pool.size()))


func _make_new_weapon_choice(data: WeaponData) -> UpgradeChoice:
	var c := UpgradeChoice.new()
	c.kind = UpgradeChoice.Kind.NEW_WEAPON
	c.item_id = data.id
	c.display_name = data.display_name
	c.description = data.description
	return c


func _make_upgrade_weapon_choice(weapon: Weapon) -> UpgradeChoice:
	var c := UpgradeChoice.new()
	c.kind = UpgradeChoice.Kind.UPGRADE_WEAPON
	c.item_id = weapon.weapon_data.id
	c.display_name = "%s Lv %d" % [weapon.display_name(), weapon.level + 1]
	c.description = weapon.weapon_data.description
	return c


func _make_new_accessory_choice(data: AccessoryData) -> UpgradeChoice:
	var c := UpgradeChoice.new()
	c.kind = UpgradeChoice.Kind.NEW_ACCESSORY
	c.item_id = data.id
	c.display_name = data.display_name
	c.description = data.description
	return c


func _make_upgrade_accessory_choice(accessory: Accessory) -> UpgradeChoice:
	var c := UpgradeChoice.new()
	c.kind = UpgradeChoice.Kind.UPGRADE_ACCESSORY
	c.item_id = accessory.accessory_data.id
	c.display_name = "%s Lv %d" % [accessory.display_name(), accessory.level + 1]
	c.description = accessory.accessory_data.description
	return c


func _make_stat_choice(boost: Dictionary) -> UpgradeChoice:
	var c := UpgradeChoice.new()
	c.kind = UpgradeChoice.Kind.STAT_BOOST
	c.stat_name = boost["stat"]
	c.stat_value = boost["value"]
	c.display_name = boost["label"]
	c.description = boost["desc"]
	return c


# -- Applying ----------------------------------------------------------------

## Applies a chosen reward and resumes the run.
func apply_choice(choice: UpgradeChoice) -> void:
	var player := GameManager.player
	match choice.kind:
		UpgradeChoice.Kind.NEW_WEAPON:
			var data := DataManager.get_weapon(choice.item_id)
			if data != null:
				player.add_weapon(data)
		UpgradeChoice.Kind.UPGRADE_WEAPON:
			var weapon := player.find_weapon(choice.item_id)
			if weapon != null:
				weapon.level_up()
		UpgradeChoice.Kind.NEW_ACCESSORY:
			var adata := DataManager.get_accessory(choice.item_id)
			if adata != null:
				player.add_accessory(adata)
		UpgradeChoice.Kind.UPGRADE_ACCESSORY:
			var accessory := player.find_accessory(choice.item_id)
			if accessory != null:
				accessory.level_up()
				player.recalculate_stats()
		UpgradeChoice.Kind.STAT_BOOST:
			_apply_stat_boost(choice)

	GameManager.unpause()
	player.finish_level_up()
	SignalBus.level_up_choice_picked.emit(choice)


func _apply_stat_boost(choice: UpgradeChoice) -> void:
	var player := GameManager.player
	var current: float = player.level_bonus.get(choice.stat_name)
	player.level_bonus.set(choice.stat_name, current + choice.stat_value)
	player.recalculate_stats()
