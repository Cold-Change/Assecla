extends Enemy

class_name EnemyScientist

@export var flask : PackedScene
@export var controlled_flask: PackedScene
@onready var projectile_spawn: Marker2D = $ProjectileSpawn

func _on_attack_check_damage() -> void:
	if is_controlled:
		if !is_instance_valid(target_enemy) || target_enemy.is_controlled:
			target_enemy = null
			return
		var f = controlled_flask.instantiate() as Projectile
		get_parent().add_child(f)
		f.global_position = projectile_spawn.global_position
		f.damage = base_damage
		f.direction = projectile_spawn.global_position.direction_to(target_enemy.global_position)
	else:
		var f = flask.instantiate() as Projectile
		get_parent().add_child(f)
		f.global_position = projectile_spawn.global_position
		f.damage = base_damage
		f.direction = projectile_spawn.global_position.direction_to(target_player.global_position)
