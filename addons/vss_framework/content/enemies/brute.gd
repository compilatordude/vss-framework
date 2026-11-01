class_name Brute
extends Enemy
## Example slow, tough enemy. Its larger size/health come from [EnemyData].


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.7, 0.2, 0.6))
