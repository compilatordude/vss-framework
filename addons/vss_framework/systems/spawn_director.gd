class_name SpawnDirector
extends Node
## Spawns enemies over the course of a run.
##
## Uses a simple time-based model: an enemy spawns every
## [member StageData.spawn_interval] seconds, and the interval shrinks over time
## (via [member StageData.spawn_ramp]) so the run gets harder. Override
## [method _spawn_enemy] or [method _current_interval] for scripted waves.

var stage_data: StageData

var _spawn_timer: float = 0.0


func setup(stage: StageData) -> void:
	stage_data = stage
	_spawn_timer = 0.0


func _process(delta: float) -> void:
	if not GameManager.is_running or stage_data == null:
		return

	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	_spawn_timer = _current_interval()

	if get_tree().get_nodes_in_group("enemies").size() >= stage_data.max_enemies:
		return
	_spawn_enemy()


## Seconds between spawns at the current elapsed time.
func _current_interval() -> float:
	var minutes := GameManager.elapsed / 60.0
	return maxf(0.1, stage_data.spawn_interval - stage_data.spawn_ramp * minutes)


## Spawns a random enemy from the stage's pool at a random world position.
func _spawn_enemy() -> void:
	if stage_data.enemy_pool.is_empty():
		return
	var id: String = stage_data.enemy_pool.pick_random()
	var data := DataManager.get_enemy(id)
	if data == null:
		return

	var enemy: Enemy = data.enemy_script.new()
	enemy.enemy_data = data
	enemy.global_position = _random_spawn_position()
	GameManager.spawn(enemy)


## Returns a random world position, kept a minimum distance from the player.
func _random_spawn_position() -> Vector2:
	var rect := GameManager.world_rect
	var pos := Vector2(
		randf_range(rect.position.x, rect.end.x),
		randf_range(rect.position.y, rect.end.y)
	)
	var player := GameManager.player
	if player != null:
		var attempts := 0
		while pos.distance_to(player.global_position) < 260.0 and attempts < 8:
			pos = Vector2(
				randf_range(rect.position.x, rect.end.x),
				randf_range(rect.position.y, rect.end.y)
			)
			attempts += 1
	return pos
