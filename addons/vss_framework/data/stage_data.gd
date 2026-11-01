class_name StageData
extends Resource
## Data-driven definition of a stage (a timed survival run).
##
## Spawning uses a simple time-based model: enemies spawn every
## [member spawn_interval] seconds, and the interval shrinks over time via
## [member spawn_ramp] so the run gets harder. Override [SpawnDirector] for
## scripted wave patterns.

## Unique id used to look the stage up in [DataManager].
@export var id: String

## Human-readable stage name.
@export var display_name: String = ""

## How long the player must survive to win, in seconds.
@export var duration_seconds: float = 1800.0

## Ids of the enemies this stage can spawn.
@export var enemy_pool: Array = []

## Seconds between spawns at the start of the run.
@export var spawn_interval: float = 1.5

## How much the spawn interval shrinks each minute (harder over time).
@export var spawn_ramp: float = 0.15

## Hard cap on how many enemies may be alive at once.
@export var max_enemies: int = 200
