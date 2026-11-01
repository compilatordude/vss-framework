class_name Projectile
extends Area2D
## A projectile fired by a [Weapon].
##
## Moves in a straight line, damages the first enemies it touches, and expires
## after [member pierce] hits or [member lifetime] seconds.

## Damage dealt on hit.
var damage: float = 1.0

## Movement speed in pixels per second.
var speed: float = 300.0

## Normalized travel direction.
var direction: Vector2 = Vector2.RIGHT

## Seconds before the projectile disappears.
var lifetime: float = 3.0

## How many enemies it can pass through before disappearing.
var pierce: int = 0


func setup(new_damage: float, new_speed: float, new_direction: Vector2, new_lifetime: float, new_pierce: int) -> void:
	damage = new_damage
	speed = new_speed
	direction = new_direction
	lifetime = new_lifetime
	pierce = new_pierce


func _ready() -> void:
	collision_layer = 4  # projectile layer
	collision_mask = 2   # detect enemies
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	shape.shape = circle
	add_child(shape)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body is Enemy:
		return
	body.take_damage(damage)
	if pierce > 0:
		pierce -= 1
	else:
		queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.9, 0.4))
