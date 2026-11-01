class_name Weapon
extends Equipment
## Base class for all weapons.
##
## A weapon auto-fires on a cooldown: [method update] counts down the cooldown
## and calls [method fire], which by default launches projectiles at the nearest
## enemies. Subclasses override [method _fire] to change behaviour (e.g. area
## damage instead of projectiles).
##
## Weapon numbers come from [WeaponData]; the owner's global stats (power, area,
## speed, duration, cooldown, amount) scale them.

var weapon_data: WeaponData

var _cooldown_timer: float = 0.0


## Initialises the weapon. Called by [method CharacterController.add_weapon].
func setup(new_owner: CharacterController, data: WeaponData) -> void:
	owner = new_owner
	weapon_data = data
	level = 1
	_cooldown_timer = 0.0
	_make_level_one()


## Hook called once after setup, at level 1.
func _make_level_one() -> void:
	pass


func is_max_level() -> bool:
	return level >= weapon_data.max_level


func level_up() -> bool:
	if is_max_level():
		return false
	level += 1
	return true


func display_name() -> String:
	return weapon_data.display_name


# -- Stat accessors (weapon base stats scaled by the owner's global stats) ----

## Returns this weapon's per-level stats: base + level_bonus for each level.
func _level_stats() -> ModifierStats:
	var s := weapon_data.base_stats.scaled(1.0)
	s.add(weapon_data.level_bonus.scaled(float(level - 1)))
	return s


## Damage dealt per hit.
func get_damage() -> float:
	return _level_stats().power * (1.0 + owner.stats.power)


## Seconds between shots.
func get_cooldown() -> float:
	return maxf(0.05, _level_stats().cooldown * (1.0 - owner.stats.cooldown))


## Hit radius (px).
func get_area() -> float:
	return _level_stats().area * (1.0 + owner.stats.area)


## Projectile speed (px/s).
func get_speed() -> float:
	return _level_stats().speed * (1.0 + owner.stats.speed)


## Projectile lifetime (s).
func get_duration() -> float:
	return _level_stats().duration * (1.0 + owner.stats.duration)


## Projectiles fired per shot.
func get_amount() -> int:
	return maxi(1, int(_level_stats().amount + owner.stats.amount))


## Enemies a single projectile can pass through.
func get_pierce() -> int:
	return weapon_data.pierce


# -- Update loop -------------------------------------------------------------

func update(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		return
	_cooldown_timer = get_cooldown()
	fire()


## Called when the cooldown expires. Delegates to [method _fire].
func fire() -> void:
	_fire()


## Default behaviour: launch projectiles at the nearest enemies.
func _fire() -> void:
	if weapon_data.is_area_weapon:
		return
	_fire_projectiles()


## Fires [method get_amount] projectiles, one at each of the nearest enemies.
func _fire_projectiles() -> void:
	var enemies := _enemies_by_distance()
	if enemies.is_empty():
		return
	var amount := get_amount()
	for i in amount:
		var target: Node2D = enemies[i % enemies.size()]
		_spawn_projectile(target)


## Instantiates a projectile aimed at [param target].
func _spawn_projectile(target: Node2D) -> void:
	var p := Projectile.new()
	var direction := (target.global_position - owner.global_position).normalized()
	p.setup(get_damage(), get_speed(), direction, get_duration(), get_pierce())
	p.global_position = owner.global_position
	GameManager.spawn(p)


## Returns all enemies sorted by distance to the owner (nearest first).
func _enemies_by_distance() -> Array:
	var nodes := owner.get_tree().get_nodes_in_group("enemies")
	var origin := owner.global_position
	nodes.sort_custom(func(a, b):
		return origin.distance_squared_to(a.global_position) < origin.distance_squared_to(b.global_position))
	return nodes
