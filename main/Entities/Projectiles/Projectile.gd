extends Area2D

class_name Projectile

var speed := 750.0
var damage := 2.0
var direction: Vector2

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	var parasite = body as Parasite
	if parasite:
		parasite.damage(damage)
	queue_free()

func _on_timer_timeout() -> void:
	queue_free()
