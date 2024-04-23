extends Powerup

var total_count = 3

func stack() -> void:
	current_stack += 1
	if current_stack < 4:
		parasite.create_tentacle()
	else:
		PowerupView.instance.powerup_registry.powerups.remove_at(3)


