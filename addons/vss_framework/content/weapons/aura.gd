class_name Aura
extends Weapon
## Example area weapon.
##
## Damages every enemy within [method Weapon.get_area] of the owner instead of
## firing projectiles. Its [WeaponData] sets [member WeaponData.is_area_weapon].


func _fire() -> void:
	var radius := get_area()
	var damage := get_damage()
	for enemy in owner.get_tree().get_nodes_in_group("enemies"):
		if owner.global_position.distance_to(enemy.global_position) <= radius:
			enemy.take_damage(damage)
