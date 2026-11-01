class_name CharacterData
extends Resource
## Data-driven definition of a playable character.
##
## Base stats live in [member base_stats]; runtime bonuses (from accessories and
## level-up picks) are layered on top at run time by [CharacterController].

## Unique id used to look the character up in [DataManager].
@export var id: String

## Human-readable name shown in menus.
@export var display_name: String = ""

## Short description shown on the character select screen.
@export_multiline var description: String = ""

## The character's base stats (max_hp and move_speed are the important ones).
@export var base_stats: ModifierStats

## Ids of the weapons the character starts the run with.
@export var starting_weapons: Array = []
