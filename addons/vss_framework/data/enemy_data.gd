class_name EnemyData
extends Resource
## Data-driven definition of an enemy.
##
## [member enemy_script] is the [Enemy] subclass that implements the enemy's
## visuals and movement. Health/damage/speed come from these exported values.

## Unique id used to look the enemy up in [DataManager].
@export var id: String

## Human-readable name (used for debugging).
@export var display_name: String = ""

## Maximum health.
@export var max_hp: float = 10.0

## Movement speed in pixels per second.
@export var move_speed: float = 80.0

## Damage dealt to the player on contact.
@export var contact_damage: float = 10.0

## Experience granted when the enemy dies.
@export var xp_value: float = 1.0

## Visual scale applied to the enemy body.
@export var scale: float = 1.0

## The [Enemy] subclass that implements this enemy's behaviour.
@export var enemy_script: GDScript
