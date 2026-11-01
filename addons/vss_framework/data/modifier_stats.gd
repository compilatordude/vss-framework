class_name ModifierStats
extends Resource
## A flat bag of additive stat values.
##
## Used in three places: character base stats, weapon/accessory bonuses, and
## runtime level-up rewards. Everything is a simple float (or int) so the values
## are visible and editable in the inspector when saved as a resource.
##
## Conventions:
##   power      — multiplier added to weapon damage (0.0 = +0%).
##   area       — multiplier added to weapon area (0.0 = +0%).
##   speed      — multiplier added to projectile speed (0.0 = +0%).
##   duration   — multiplier added to effect duration (0.0 = +0%).
##   cooldown   — fraction subtracted from weapon cooldown (0.0 = -0%).
##   amount     — extra projectiles added per shot.
##   move_speed — extra movement speed added to the character (px/s).
##   max_hp     — extra maximum health added to the character.
##   magnet     — extra pickup attraction radius (px).
##   luck       — scales drop rarity and crit chance.
##   growth     — extra experience gained (0.0 = +0%).
##   greed      — extra coin/gold gained (0.0 = +0%).
##   regen      — health regenerated per second.
##   armor      — flat damage reduction per hit.
##   thorns     — damage reflected back on contact.
##   curse      — increases enemy health/spawn rate for bonus rewards.

@export var power: float = 0.0
@export var area: float = 0.0
@export var speed: float = 0.0
@export var move_speed: float = 0.0
@export var growth: float = 0.0
@export var luck: float = 0.0
@export var duration: float = 0.0
@export var cooldown: float = 0.0
@export var amount: float = 0.0
@export var shields: float = 0.0
@export var armor: float = 0.0
@export var greed: float = 0.0
@export var regen: float = 0.0
@export var revivals: float = 0.0
@export var rerolls: float = 0.0
@export var skips: float = 0.0
@export var max_hp: float = 0.0
@export var magnet: float = 0.0
@export var curse: float = 0.0
@export var banish: float = 0.0
@export var shroud: float = 0.0
@export var charm: int = 0
@export var defang: float = 0.0
@export var thorns: float = 0.0
@export var invul_time_bonus: float = 0.0
@export var fever: float = 0.0
@export var recycle: float = 0.0


## Sets every value back to zero.
func reset() -> void:
	power = 0.0
	area = 0.0
	speed = 0.0
	move_speed = 0.0
	growth = 0.0
	luck = 0.0
	duration = 0.0
	cooldown = 0.0
	amount = 0.0
	shields = 0.0
	armor = 0.0
	greed = 0.0
	regen = 0.0
	revivals = 0.0
	rerolls = 0.0
	skips = 0.0
	max_hp = 0.0
	magnet = 0.0
	curse = 0.0
	banish = 0.0
	shroud = 0.0
	charm = 0
	defang = 0.0
	thorns = 0.0
	invul_time_bonus = 0.0
	fever = 0.0
	recycle = 0.0


## Adds another stats bag onto this one and returns self (for chaining).
func add(other: ModifierStats) -> ModifierStats:
	power += other.power
	area += other.area
	speed += other.speed
	move_speed += other.move_speed
	growth += other.growth
	luck += other.luck
	duration += other.duration
	cooldown += other.cooldown
	amount += other.amount
	shields += other.shields
	armor += other.armor
	greed += other.greed
	regen += other.regen
	revivals += other.revivals
	rerolls += other.rerolls
	skips += other.skips
	max_hp += other.max_hp
	magnet += other.magnet
	curse += other.curse
	banish += other.banish
	shroud += other.shroud
	charm += other.charm
	defang += other.defang
	thorns += other.thorns
	invul_time_bonus += other.invul_time_bonus
	fever += other.fever
	recycle += other.recycle
	return self


## Returns a new stats bag with every value multiplied by [param factor].
func scaled(factor: float) -> ModifierStats:
	var result := ModifierStats.new()
	result.power = power * factor
	result.area = area * factor
	result.speed = speed * factor
	result.move_speed = move_speed * factor
	result.growth = growth * factor
	result.luck = luck * factor
	result.duration = duration * factor
	result.cooldown = cooldown * factor
	result.amount = amount * factor
	result.shields = shields * factor
	result.armor = armor * factor
	result.greed = greed * factor
	result.regen = regen * factor
	result.revivals = revivals * factor
	result.rerolls = rerolls * factor
	result.skips = skips * factor
	result.max_hp = max_hp * factor
	result.magnet = magnet * factor
	result.curse = curse * factor
	result.banish = banish * factor
	result.shroud = shroud * factor
	result.charm = int(charm * factor)
	result.defang = defang * factor
	result.thorns = thorns * factor
	result.invul_time_bonus = invul_time_bonus * factor
	result.fever = fever * factor
	result.recycle = recycle * factor
	return result
