extends Node
class_name PowerupRegistry

var powerups:Array[PackedScene]

func _init() -> void:
	powerups.append(load("res://Entities/Powerups/MovementPowerup/movement_powerup.tscn"))
	powerups.append(load("res://Entities/Powerups/CoreHealthPowerup/CoreHealthPowerup.tscn"))
	powerups.append(load("res://Entities/Powerups/OmegaPowerup/OmegaPowerup.tscn"))
	powerups.append(load("res://Entities/Powerups/TentaIncrease/TentacleIncrease.tscn"))
	powerups.append(load("res://Entities/Powerups/PosessedPowerup/posessed_powerup.tscn"))
	powerups.append(load("res://Entities/Powerups/DamageUp/DamageUp.tscn"))
	
func get_random_instance() -> Powerup:
	return (powerups.pick_random() as PackedScene).instantiate()
