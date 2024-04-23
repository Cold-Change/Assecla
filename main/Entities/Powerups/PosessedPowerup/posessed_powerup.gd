extends Powerup

var total_count = 3

func stack() -> void:
	parasite.posession_damage_increase += 1
	parasite.increase_damage_controlled(1)
