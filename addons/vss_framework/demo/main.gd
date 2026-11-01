extends Node2D
## Entry point: registers example content, builds the world and starts a run.


func _ready() -> void:
	ExampleContent.register_all()
	_setup_world()
	_start_run()


func _setup_world() -> void:
	var spawn_director := SpawnDirector.new()
	spawn_director.name = "SpawnDirector"
	add_child(spawn_director)
	spawn_director.setup(DataManager.get_stage("grasslands"))

	var level_up_system := LevelUpSystem.new()
	level_up_system.name = "LevelUpSystem"
	add_child(level_up_system)

	add_child(HUD.new())

	var level_up_screen := LevelUpScreen.new()
	level_up_screen.level_up_system = level_up_system
	add_child(level_up_screen)


func _start_run() -> void:
	var character := CharacterController.new()
	character.character_data = DataManager.get_character("demo")
	add_child(character)
	character.position = Vector2.ZERO

	# Camera follows the player.
	var camera := Camera2D.new()
	camera.enabled = true
	character.add_child(camera)

	GameManager.start_run(character, DataManager.get_stage("grasslands"))
