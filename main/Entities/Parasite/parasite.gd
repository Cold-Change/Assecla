extends CharacterBody2D
class_name Parasite

@export var speed := 300.0
@export var tentacle_speed := 20.0
@export var base_damage := 2.0
@export var max_health := 10.0
@export var health := 10.0

@onready
var possessManager : PossessManager = $PossessManager as PossessManager
var tentacle_obj := preload("res://Entities/Parasite/tentacle.tscn")
var tentacles : Array[Tentacle] = []

@onready var state_chart: StateChart = $StateChart
@onready var attack_base: Node2D = $Attacks
@onready var attack1_hitbox: Area2D = $Attacks/MiddleAtttackHitbox
@onready var attack2_hitbox: Area2D = $Attacks/WideAttackHitbox
#@onready var ovani_player: OvaniPlayer = $OvaniPlayer

@export var powerup_view:PowerupView
@export var gameover_view:GameOverView
@export var healthbar:TextureProgressBar
@export var xpbar:TextureProgressBar
@export var enemy_spawn:EnemySpawner

var posession_damage_increase:int
var threat_count := -1

signal on_enemy_controlled

func _ready() -> void:
	randomize()
	#update_intensity()
	possessManager.player = self
	powerup_view.on_powerup.connect(add_powerup)
	# HACK: this is only done to bubble it up...
	possessManager.on_enemy_controlled.connect(_on_enemy_controlled)
	for i in range(5):
		create_tentacle()
	
func create_tentacle() -> void:
	var tentacle := tentacle_obj.instantiate() as Tentacle
	tentacle.possess_enemy = possessManager.control_enemy
	add_child(tentacle)
	move_child(tentacle, 0)
	tentacles.append(tentacle)

var posessed_count = 0
func _on_enemy_controlled(enemy:Enemy) -> void:
	posessed_count += 1
	enemy.base_damage += posession_damage_increase + 5 # Default increase.
	on_enemy_controlled.emit()
	
func get_idle_tentacle() -> Tentacle:
	var idle_tentacles := tentacles.filter(func(i: Tentacle) -> bool: return i.is_idle)
	if idle_tentacles.is_empty():
		return null
	else:
		return idle_tentacles[0]

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
		
	if Input.is_action_just_pressed("fire_secondary"):
		shoot_tentacle()
	
	move_and_slide()

@export var game_time_label:Label

func _process(_delta: float) -> void:
	healthbar.max_value = max_health
	healthbar.min_value = 0
	healthbar.value = health
	
	xpbar.max_value = max_xp
	xpbar.min_value = 0
	xpbar.value = current_xp
	#game_time_label.text = "( %02d:%02d:%02d )" % [fmod(enemy_spawn.current_game_time	/3600, 24), fmod(enemy_spawn.current_game_time	/60, 60), fmod(enemy_spawn.current_game_time, 60)]
	

func shoot_tentacle() -> void:
	var space_state := get_world_2d().direct_space_state
	# use global coordinates, not local to node
	var query := PhysicsPointQueryParameters2D.new()
	query.position = get_global_mouse_position()
	var result := space_state.intersect_point(query, 1)
	if result and result[0].collider is Enemy:
		var enemy := result[0].collider as Enemy
		if enemy.is_controlled:
			return
		var tentacle := get_idle_tentacle()
		if tentacle != null:
			tentacle.set_target_enemy(result[0].collider)

func damage(amount:float) -> void:
	DamageNumbersServer.go(str(round(amount)), global_position)
	health -= amount
	if health <= 0:
		#state_chart.send_event("death")
		die()
	else:
		#state_chart.send_event("hurt")
		pass
	#update_intensity()

func heal(amount:float) -> void:
	DamageNumbersServer.go_heal(round(amount), global_position)
	health += amount
	health = min(health, max_health)
	#update_intensity()

func die() -> void:
	#ovani_player.Intensity = 0
	gameover_view.set_model(self)
	gameover_view.transition_on()

func level_up() -> void:
	powerup_view.TransitionOn()

var powerups:Dictionary

var powerup_count:int
func add_powerup(powerup:Powerup) -> void:
	var applied_powerup:Powerup = powerup
	powerup_count += 1
	if powerups.has(powerup.powerup_name):
		powerup.queue_free()
		applied_powerup = powerups[powerup.powerup_name]
		applied_powerup.stack()
	else:
		powerups[applied_powerup.powerup_name] = applied_powerup
		add_child(applied_powerup)

var current_xp:int = 0
var max_xp:int = 5

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Biomass:
		var bio:Biomass = area.get_parent()
		bio.queue_free()
		current_xp += bio.xp_value
		if current_xp >= max_xp:
			level_up()
			current_xp = 0
			max_xp += int(round(max_xp * 0.5))

func get_powerup_count() -> int:
	return powerup_count
	
func get_enemy_kills() -> int:
	return enemy_spawn.enemies_killed
	
func get_enemy_posessed() -> int:
	return posessed_count

func get_time_survived() -> int:
	return round(enemy_spawn.current_game_time)
			
func _on_attack1_calculate_damage() -> void:
	deal_damage(attack1_hitbox)
	
func _on_attack2_calculate_damage() -> void:
	deal_damage(attack2_hitbox)
	
func deal_damage(hitbox: Area2D) -> void:
	var targets : Array[Enemy] = []
	targets.assign(hitbox.get_overlapping_bodies().filter(func(i: Node2D) -> bool: return i is Enemy and !(i as Enemy).is_controlled))
	if targets.is_empty():
		return
	
	var block_targets : Array[Enemy] = targets.filter(func(i: Enemy) -> bool: return i.can_block_damage())
	if !block_targets.is_empty():
		var total_damage := maxf(base_damage * float(targets.size() - block_targets.size()) / block_targets.size(), 1)
		for target in block_targets:
			target.damage(total_damage)
		return
	
	for target in targets:
		target.damage(base_damage)

func _on_idle_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_primary"):
		state_chart.send_event("attack")
		attack_base.look_at(get_global_mouse_position())

func _on_wait_for_attack_1_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_primary"):
		state_chart.send_event("attack")
		attack_base.look_at(get_global_mouse_position())


func _on_wait_for_attack_2_state_physics_processing(_delta: float) -> void:
	if Input.is_action_just_pressed("fire_primary"):
		state_chart.send_event("attack2")
		attack_base.look_at(get_global_mouse_position())

func increase_damage_controlled(amount:int) -> void:
	for enemy:Enemy in possessManager.enemies:
		enemy.base_damage += amount

#func update_intensity() -> void:
	#var intensity := 0.0
	#if threat_count > 2:
		#intensity += .2
	#if threat_count > 5:
		#intensity += .3
	#if health < max_health / 2:
		#intensity += .3
	#if health < max_health / 4:
		#intensity += .2
	
	#ovani_player.FadeIntensity(intensity, .5)

func _on_threat_range_body_entered(body: Node2D) -> void:
	threat_count += 1


func _on_threat_range_body_exited(body: Node2D) -> void:
	threat_count -= 1
