class_name CharacterController
extends CharacterBody2D
## The player character.
##
## Handles movement, health, experience/levelling, and owns the run's weapons
## and accessories. Effective stats are computed by layering base stats,
## level-up stat boosts and accessory bonuses (see [method recalculate_stats]).

## The data this character was created from.
var character_data: CharacterData

var level: int = 1
var xp: float = 0.0
var xp_to_next: float = 5.0
var is_leveling_up: bool = false

# Stat layers. [member stats] is the cached effective result.
var base_stats: ModifierStats
var level_bonus: ModifierStats
var stats: ModifierStats

var max_hp: float = 100.0
var hp: float = 100.0
var move_speed: float = 200.0
var magnet_radius: float = 60.0

var weapons: Array = []
var accessories: Array = []


func _ready() -> void:
	_build_body()
	level_bonus = ModifierStats.new()
	if character_data != null:
		_apply_character_data()


func _build_body() -> void:
	collision_layer = 1  # player layer
	collision_mask = 0   # no physical collision in the base framework
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 12.0
	shape.shape = circle
	add_child(shape)


func _apply_character_data() -> void:
	base_stats = character_data.base_stats
	for weapon_id in character_data.starting_weapons:
		var data := DataManager.get_weapon(weapon_id)
		if data != null:
			add_weapon(data)
	recalculate_stats()
	hp = max_hp


# -- Stats -------------------------------------------------------------------

## Recomputes [member stats] from base stats + level bonuses + accessories.
func recalculate_stats() -> void:
	var old_max := max_hp
	stats = base_stats.scaled(1.0) if base_stats != null else ModifierStats.new()
	stats.add(level_bonus)
	for accessory in accessories:
		stats.add(accessory.get_current_stats())
	max_hp = stats.max_hp
	move_speed = stats.move_speed
	magnet_radius = 60.0 + stats.magnet
	# Keep hp and heal by any increase in max hp.
	hp = minf(max_hp, hp + (max_hp - old_max))


# -- Frame update ------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not GameManager.is_running:
		return

	velocity = _input_vector() * move_speed
	move_and_slide()
	global_position = global_position.clamp(GameManager.world_rect.position, GameManager.world_rect.end)

	if stats.regen > 0.0:
		hp = minf(max_hp, hp + stats.regen * delta)

	for weapon in weapons:
		weapon.update(delta)
	for accessory in accessories:
		accessory.update(delta)


func _input_vector() -> Vector2:
	var v := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		v.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		v.x += 1.0
	if Input.is_key_pressed(KEY_W):
		v.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		v.y += 1.0
	if v.length() > 1.0:
		v = v.normalized()
	return v


# -- Health ------------------------------------------------------------------

func take_damage(amount: float) -> void:
	if not GameManager.is_running:
		return
	var actual := maxf(1.0, amount - stats.armor)
	hp -= actual
	SignalBus.player_hp_changed.emit(hp, max_hp)
	if hp <= 0.0:
		_die()


func _die() -> void:
	set_physics_process(false)
	hide()
	SignalBus.player_died.emit()


# -- Experience / levelling --------------------------------------------------

func gain_xp(amount: float) -> void:
	xp += amount * (1.0 + stats.growth)
	SignalBus.xp_changed.emit(xp, xp_to_next)
	_check_level_up()


func _check_level_up() -> void:
	if is_leveling_up or xp < xp_to_next:
		return
	is_leveling_up = true
	xp -= xp_to_next
	level += 1
	xp_to_next = _xp_threshold(level)
	recalculate_stats()
	SignalBus.player_leveled_up.emit(level)
	SignalBus.xp_changed.emit(xp, xp_to_next)


## Called by the level-up system after a choice has been applied.
func finish_level_up() -> void:
	is_leveling_up = false
	_check_level_up()


## How much xp is needed to go from [param lvl] to the next level.
func _xp_threshold(lvl: int) -> float:
	return 5.0 + float(lvl - 1) * 5.0


# -- Equipment management ----------------------------------------------------

## Adds a weapon of the given data and returns the new [Weapon].
func add_weapon(data: WeaponData) -> Weapon:
	var weapon: Weapon = data.weapon_script.new()
	weapon.setup(self, data)
	weapons.append(weapon)
	return weapon


## Adds an accessory of the given data and returns the new [Accessory].
func add_accessory(data: AccessoryData) -> Accessory:
	var accessory: Accessory = data.accessory_script.new()
	accessory.setup(self, data)
	accessories.append(accessory)
	recalculate_stats()
	return accessory


## Returns the owned weapon with the given data id, or null.
func find_weapon(id: String) -> Weapon:
	for weapon in weapons:
		if weapon.weapon_data.id == id:
			return weapon
	return null


## Returns the owned accessory with the given data id, or null.
func find_accessory(id: String) -> Accessory:
	for accessory in accessories:
		if accessory.accessory_data.id == id:
			return accessory
	return null


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.4, 0.6, 1.0))
