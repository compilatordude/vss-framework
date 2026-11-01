extends Node
## Autoload singleton that owns a run's high-level state.
##
## Tracks elapsed time, the active player, and the victory/defeat conditions.
## Spawn pacing and difficulty live in [SpawnDirector]; this node just drives the
## clock and the win/lose transitions.

## The active player character for the current run.
var player: CharacterController = null

## The stage definition for the current run.
var stage_data: StageData = null

## Seconds elapsed since the run started.
var elapsed: float = 0.0

## True while a run is actively being played.
var is_running: bool = false

## World-space bounds used by spawn logic. Set by the main scene.
var world_rect: Rect2 = Rect2(-900.0, -500.0, 1800.0, 1000.0)


func _process(delta: float) -> void:
	if not is_running:
		return
	elapsed += delta
	if stage_data != null and elapsed >= stage_data.duration_seconds:
		_win()


## Begins a run with the given player and stage.
func start_run(new_player: CharacterController, stage: StageData) -> void:
	player = new_player
	stage_data = stage
	elapsed = 0.0
	is_running = true
	SignalBus.run_started.emit()


## Freezes gameplay (e.g. while the level-up screen is open).
func pause() -> void:
	get_tree().paused = true


## Resumes gameplay.
func unpause() -> void:
	get_tree().paused = false


## Adds a node to the current scene root. Used to spawn projectiles, pickups
## and enemies without needing a hard reference to the world.
func spawn(node: Node) -> void:
	get_tree().current_scene.add_child(node)


func _win() -> void:
	if not is_running:
		return
	is_running = false
	SignalBus.game_won.emit()


func _lose() -> void:
	if not is_running:
		return
	is_running = false
	SignalBus.game_over.emit()


func _ready() -> void:
	SignalBus.player_died.connect(_lose)
