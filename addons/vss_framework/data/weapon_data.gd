class_name WeaponData
extends Resource
## Data-driven definition of a weapon.
##
## A weapon's numbers come from its [member base_stats] plus [member level_bonus]
## applied once per level beyond the first. [member weapon_script] is the
## [Weapon] subclass that implements how the weapon actually fires.

## Unique id used to look the weapon up in [DataManager].
@export var id: String

## Human-readable name shown in the level-up screen.
@export var display_name: String = ""

## Short description shown in the level-up screen.
@export_multiline var description: String = ""

## Highest level this weapon can reach.
@export var max_level: int = 8

## Stats granted at level 1. `power` is the base damage, `cooldown` is seconds
## between shots, `area` is the hit radius, `speed` is projectile speed,
## `duration` is projectile lifetime and `amount` is projectiles per shot.
@export var base_stats: ModifierStats

## Additional stats granted for every level beyond the first.
@export var level_bonus: ModifierStats

## How many enemies a single projectile can pass through before disappearing.
@export var pierce: int = 0

## The [Weapon] subclass that implements this weapon's firing behaviour.
@export var weapon_script: GDScript

## The projectile scene this weapon spawns. Ignored by area weapons.
@export var projectile_scene: PackedScene

## When true the weapon has no projectile and instead damages a radius around
## the owner on a cooldown.
@export var is_area_weapon: bool = false
