class_name AccessoryData
extends Resource
## Data-driven definition of a passive accessory.
##
## Accessories grant [member stats] (plus [member level_bonus] per extra level)
## to the owning character. [member accessory_script] is the [Accessory]
## subclass that applies the effect.

## Unique id used to look the accessory up in [DataManager].
@export var id: String

## Human-readable name shown in the level-up screen.
@export var display_name: String = ""

## Short description shown in the level-up screen.
@export_multiline var description: String = ""

## Highest level this accessory can reach.
@export var max_level: int = 5

## Stats granted at level 1.
@export var stats: ModifierStats

## Additional stats granted for every level beyond the first.
@export var level_bonus: ModifierStats

## The [Accessory] subclass that applies this accessory's effect.
@export var accessory_script: GDScript
