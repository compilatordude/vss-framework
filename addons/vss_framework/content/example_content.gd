class_name ExampleContent
extends RefCounted
## Registers a small set of example content so the framework runs out of the box.
##
## A minimal example: a demo character, two weapons, one accessory, two enemies
## and one stage. Replace or extend it with your own content, or load data from
## .tres resources instead of building it in code.


static func register_all() -> void:
	_register_characters()
	_register_weapons()
	_register_accessories()
	_register_enemies()
	_register_stages()


## Builds a [ModifierStats] from a dictionary of `{property: value}` pairs.
static func _stats(values: Dictionary = {}) -> ModifierStats:
	var s := ModifierStats.new()
	for key in values:
		s.set(key, values[key])
	return s


static func _register_characters() -> void:
	var d := CharacterData.new()
	d.id = "demo"
	d.display_name = "Demo"
	d.description = "A balanced starting character."
	d.base_stats = _stats({"max_hp": 100.0, "move_speed": 200.0})
	d.starting_weapons = ["wand"]
	DataManager.register_character(d)


static func _register_weapons() -> void:
	var wand := WeaponData.new()
	wand.id = "wand"
	wand.display_name = "Wand"
	wand.description = "Fires a bolt at the nearest enemy."
	wand.max_level = 8
	wand.base_stats = _stats({"power": 8.0, "cooldown": 1.2, "area": 10.0, "speed": 400.0, "duration": 2.0, "amount": 1.0})
	wand.level_bonus = _stats({"power": 2.0, "cooldown": -0.08})
	wand.pierce = 0
	wand.weapon_script = preload("res://addons/vss_framework/content/weapons/wand.gd")
	wand.is_area_weapon = false
	DataManager.register_weapon(wand)

	var aura := WeaponData.new()
	aura.id = "aura"
	aura.display_name = "Aura"
	aura.description = "Damages enemies around you."
	aura.max_level = 8
	aura.base_stats = _stats({"power": 5.0, "cooldown": 1.5, "area": 90.0})
	aura.level_bonus = _stats({"power": 1.5, "area": 10.0, "cooldown": -0.05})
	aura.weapon_script = preload("res://addons/vss_framework/content/weapons/aura.gd")
	aura.is_area_weapon = true
	DataManager.register_weapon(aura)


static func _register_accessories() -> void:
	var amulet := AccessoryData.new()
	amulet.id = "vitality_amulet"
	amulet.display_name = "Vitality Amulet"
	amulet.description = "Grants bonus maximum health."
	amulet.max_level = 5
	amulet.stats = _stats({"max_hp": 25.0})
	amulet.level_bonus = _stats({"max_hp": 10.0})
	amulet.accessory_script = preload("res://addons/vss_framework/content/accessories/vitality_amulet.gd")
	DataManager.register_accessory(amulet)


static func _register_enemies() -> void:
	var chaser := EnemyData.new()
	chaser.id = "chaser"
	chaser.display_name = "Chaser"
	chaser.max_hp = 10.0
	chaser.move_speed = 90.0
	chaser.contact_damage = 5.0
	chaser.xp_value = 1.0
	chaser.scale = 1.0
	chaser.enemy_script = preload("res://addons/vss_framework/content/enemies/chaser.gd")
	DataManager.register_enemy(chaser)

	var brute := EnemyData.new()
	brute.id = "brute"
	brute.display_name = "Brute"
	brute.max_hp = 40.0
	brute.move_speed = 55.0
	brute.contact_damage = 15.0
	brute.xp_value = 4.0
	brute.scale = 2.0
	brute.enemy_script = preload("res://addons/vss_framework/content/enemies/brute.gd")
	DataManager.register_enemy(brute)


static func _register_stages() -> void:
	var stage := StageData.new()
	stage.id = "grasslands"
	stage.display_name = "Grasslands"
	stage.duration_seconds = 300.0
	stage.enemy_pool = ["chaser", "brute"]
	stage.spawn_interval = 1.5
	stage.spawn_ramp = 0.1
	stage.max_enemies = 150
	DataManager.register_stage(stage)
