extends Projectile

func _on_body_entered(body):
	var enemy = body as Enemy
	if enemy != null && !enemy.is_controlled:
		enemy.damage(damage)
		queue_free()
