extends Node2D
class_name PossessManager

var enemies : Array[Enemy] = []
@export var offset_area_radius := 80.0
@export var rotation_rate := .5
var player : CharacterBody2D

var rotation_position := 0.0

signal on_enemy_controlled(enemy)

func _physics_process(_delta: float) -> void:
	var i := 0
	var ring_rotation := 2 * PI / enemies.size()
	rotation_position += _delta * rotation_rate
	for enemy in enemies:
		if is_instance_valid(enemy):
			var circle_rot := i * ring_rotation + rotation_position
			enemy.target_location = player.global_position + (offset_area_radius * Vector2(cos(circle_rot), sin(circle_rot)))
			i += 1

func controlled_enemy_died(enemy:Enemy) -> void:
	enemies.erase(enemy)
	
func control_enemy(enemy: Enemy) -> bool:
	if enemy.is_controlled:
		return false
	if enemies.find(enemy) == -1:
		on_enemy_controlled.emit(enemy)
		enemy.on_death.connect(controlled_enemy_died)
		enemies.append(enemy)
		enemy.control_enemy()
	else:
		assert(false, "Tried to add an already controlled enemy to PossessManager")
	
	return true
