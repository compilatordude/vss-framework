class_name Pickup
extends Area2D
## A collectible dropped by enemies (experience gems by default).
##
## Sits still until the player comes within magnet range, then flies toward the
## player and is collected on contact.

## Experience (or other value) granted on collection.
var value: float = 1.0

## Speed at which the pickup flies toward the player once attracted.
var pickup_speed: float = 400.0


func _ready() -> void:
	collision_layer = 8  # pickup layer
	collision_mask = 1   # detect the player
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var player := GameManager.player
	if player == null:
		return
	var magnet_radius: float = 60.0 + player.stats.magnet
	if global_position.distance_to(player.global_position) < magnet_radius:
		global_position = global_position.move_toward(player.global_position, pickup_speed * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterController:
		_collect(body)


func _collect(player: CharacterController) -> void:
	player.gain_xp(value)
	SignalBus.pickup_collected.emit(self)
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(0.3, 0.9, 0.5))
