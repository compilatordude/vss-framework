class_name Enemy
extends CharacterBody2D
## Base class for all enemies.
##
## Walks toward the player, deals contact damage on a cooldown, and drops an
## experience pickup on death. Subclasses override [method _draw] (and any
## movement hooks) to change appearance and behaviour.

## The data this enemy was spawned from.
var enemy_data: EnemyData

var max_hp: float = 10.0
var hp: float = 10.0
var move_speed: float = 80.0
var contact_damage: float = 10.0
var xp_value: float = 1.0

var _attack_interval: float = 0.5
var _attack_timer: float = 0.0
var _contact_bodies: Array = []


func _ready() -> void:
	_build_body()
	_apply_data()
	add_to_group("enemies")


func _build_body() -> void:
	collision_layer = 2  # enemy layer (detected by projectiles)
	collision_mask = 0   # no physical collision

	var body_shape := CollisionShape2D.new()
	var body_circle := CircleShape2D.new()
	body_circle.radius = 12.0
	body_shape.shape = body_circle
	add_child(body_shape)

	# Contact area that detects the player for contact damage.
	var contact := Area2D.new()
	contact.collision_layer = 0
	contact.collision_mask = 1  # player layer
	var contact_shape := CollisionShape2D.new()
	var contact_circle := CircleShape2D.new()
	contact_circle.radius = 14.0
	contact_shape.shape = contact_circle
	contact.add_child(contact_shape)
	add_child(contact)
	contact.body_entered.connect(_on_contact_entered)
	contact.body_exited.connect(_on_contact_exited)


func _apply_data() -> void:
	max_hp = enemy_data.max_hp
	hp = max_hp
	move_speed = enemy_data.move_speed
	contact_damage = enemy_data.contact_damage
	xp_value = enemy_data.xp_value
	scale = Vector2(enemy_data.scale, enemy_data.scale)


func _physics_process(delta: float) -> void:
	var player := GameManager.player
	if player == null or not GameManager.is_running:
		return

	var dir := (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()

	_attack_timer -= delta
	if not _contact_bodies.is_empty() and _attack_timer <= 0.0:
		_attack_timer = _attack_interval
		player.take_damage(contact_damage)


func _on_contact_entered(body: Node2D) -> void:
	if body is CharacterController and body not in _contact_bodies:
		_contact_bodies.append(body)


func _on_contact_exited(body: Node2D) -> void:
	_contact_bodies.erase(body)


## Called when hit by a projectile (or other damage source).
func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp -= amount
	if hp <= 0.0:
		die()


func die() -> void:
	SignalBus.enemy_died.emit(self, xp_value)
	var gem := Pickup.new()
	gem.value = xp_value
	gem.global_position = global_position
	GameManager.spawn(gem)
	queue_free()


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.3, 0.3))
