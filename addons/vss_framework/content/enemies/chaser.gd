class_name Chaser
extends Enemy
## Example fast, weak enemy. Inherits default chase behaviour from [Enemy].


func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.9, 0.4, 0.2))
