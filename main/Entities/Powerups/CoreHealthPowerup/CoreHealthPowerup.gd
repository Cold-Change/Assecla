extends Powerup

func stack() -> void:
	current_stack += 1
	parasite.max_health += 2
