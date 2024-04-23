extends CharacterBody2D
class_name Enemy

@export var health := 10.0
@export var normal_speed := 150.0
@export var controlled_speed := 350.0
@export var base_damage := 1.0


@onready var nav_agent : NavigationAgent2D = $NavigationAgent2D
@onready var sprite : Sprite2D = $Sprite2D
@onready var state_chart : StateChart = $StateChart
@onready var attack_range : Area2D = $AttackRange
@onready var seek_range : Area2D = $ControlledSeekRange
@onready var damage_range : Area2D = $DamageRange

@onready var target_player : Parasite = $"../Parasite"

@export var min_xp:float = 1
@export var max_xp:float = 3

@export var possessed_sprite: Texture2D

var target_location : Vector2
var target_enemy : Enemy
var is_controlled := false

signal on_death(enemy:Enemy)

func _on_controlled_state_state_entered() -> void:
	is_controlled = true

func move_towards_target_position(target: Vector2, speed: float, delta: float, clamp_speed: bool = false) -> void:
	nav_agent.target_position = target
	var next_path_pos := nav_agent.get_next_path_position()
	var calc_speed := clampf(speed, 0, global_position.distance_to(next_path_pos) / delta) if clamp_speed else speed
	velocity = global_position.direction_to(next_path_pos) * calc_speed
	move_and_slide()
	sprite.flip_h = velocity.x < 0

func _on_chase_physics_processing(delta: float) -> void:
	move_towards_target_position(target_player.global_position, normal_speed, delta)

func _on_go_home_state_entered() -> void:
	target_enemy = null

func _on_go_home_state_physics_processing(delta: float) -> void:
	move_towards_target_position(target_location, controlled_speed, delta)
	if global_position.distance_to(target_location) < 10:
		state_chart.send_event("seek")

func _on_seek_state_physics_processing(delta: float) -> void:
	move_towards_target_position(target_location, controlled_speed, delta, true)
	var targets : Array[Enemy] = []
	targets.assign(seek_range.get_overlapping_bodies().filter(func(i: Node2D) -> bool: return i is Enemy and !(i as Enemy).is_controlled))
	if !targets.is_empty():
		target_enemy = targets[0]
		state_chart.send_event("chase")

func _on_chase_state_physics_processing(delta: float) -> void:
	if !is_instance_valid(target_enemy) || target_enemy.is_controlled:
		target_enemy = null
		state_chart.send_event("go_home")
		return
		
	move_towards_target_position(target_enemy.global_position, controlled_speed, delta)

func _on_attack_check(_delta: float) -> void:
	if attack_range.overlaps_body(target_player):
		state_chart.send_event("attack")

func _on_attack_check_damage() -> void:
	if is_controlled:
		if damage_range.overlaps_body(target_enemy):
			target_enemy.damage(base_damage)
	else:
		if damage_range.overlaps_body(target_player):
			target_player.damage(base_damage)

func _on_controlled_attack_check(_delta: float) -> void:
	if attack_range.overlaps_body(target_enemy):
		state_chart.send_event("attack")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		state_chart.send_event("attack_end")

func damage(amount:float) -> void:
	if health <= 0:
		return
	DamageNumbersServer.go(str(round(amount)), global_position)
	health -= amount
	if health <= 0:
		state_chart.send_event("death")
	else:
		state_chart.send_event("hurt")

func _on_death() -> void:
	collision_layer = 0
	collision_mask = 0
	on_death.emit(self)
	
func _on_normal_death_state_entered() -> void:
	var current_biomass:Biomass = (load("res://Entities/Biomass/Biomass.tscn") as PackedScene).instantiate()
	current_biomass.global_position = global_position
	current_biomass.xp_value = randi_range(min_xp, max_xp)
	get_parent().add_child(current_biomass)
	_on_death()

func _on_controlled_death_state_entered() -> void:
	_on_death()
	
func _on_cleanup_state_entered() -> void:
	queue_free()

func control_enemy() -> void:
	state_chart.send_event("controlled")
	set_collision_layer_value(1, false)
	sprite.texture = possessed_sprite

func scale(time:float) -> void:
	health += time * 0.25
	normal_speed += time * 0.001
	normal_speed = min(normal_speed, controlled_speed-50)
	
func can_block_damage() -> bool:
	return false
