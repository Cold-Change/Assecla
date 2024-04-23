extends Node2D
class_name EnemySpawner

@export var spawn_parent:Node2D
@export var tile_map:TileMap
@export var navigation:NavigationRegion2D
@export var spawn_points: Array[Marker2D]

# Internal data class to manage when to start spawning an enemy
# and how often to spawn them.
class EnemyData:
	var scene:PackedScene
	var time_to_spawn:float
	var rarity:float
	
	func _init(scen:PackedScene, time:float, rarity:float) -> void:
		scene = scen
		time_to_spawn = time

var all_enemies:Array[EnemyData] = [
	EnemyData.new(load("res://Entities/Enemy/enemy_rat.tscn"), 0.0, 10),
	EnemyData.new(load("res://Entities/Enemy/enemy_security.tscn"), 10.0, 10),
	EnemyData.new(load("res://Entities/Enemy/enemy_shield.tscn"), 20.0, 10),
	EnemyData.new(load("res://Entities/Enemy/enemy_scientist.tscn"), 30.0, 10),
	EnemyData.new(load("res://Entities/Enemy/enemy_elite_security.tscn"), 40.0, 10),
]

var available_enemies:Array[EnemyData] = []

var timer:Timer = Timer.new()
var current_game_time:float
var max_enemies:int = 40
var current_enemies:int = 0

func start_spawning() -> void:
	add_child(timer)
	timer.wait_time = 2.0
	timer.one_shot = false
	timer.timeout.connect(_on_spawn)
	timer.start()

func _process(delta: float) -> void:
	if !timer.is_stopped():
		current_game_time += delta
	
	_update_available_enemies()

func _on_spawn() -> void:
	#TODO: It would be better if we projected to the
	# first tile that 
	if current_enemies > max_enemies || available_enemies.size() == 0:
		return
	
	var new_position:Vector2 = spawn_points.pick_random().global_position
	
	var random_enemy:EnemyData = available_enemies.pick_random()
	var new_instance:Enemy = random_enemy.scene.instantiate()
	new_instance.on_death.connect(_enemy_died)
	new_instance.position = new_position
	new_instance.scale(current_game_time)
	spawn_parent.add_child(new_instance)
	timer.wait_time -= 0.01
	timer.wait_time = max(0.25, timer.wait_time)
	current_enemies += 1
	

var enemies_killed:int = 0
func _enemy_died(enem):
	enemies_killed += 1
	current_enemies -= 1

func _update_available_enemies() -> void:
	if all_enemies.size() > 0:
		var current:EnemyData = all_enemies[0]
		if current.time_to_spawn < current_game_time:
			all_enemies.remove_at(0)
			available_enemies.append(current)

func is_position_free(position:Vector2) -> bool:
	var tile_position:Vector2i = tile_map.local_to_map(position)
	var tile_id:TileData = tile_map.get_cell_tile_data(0, tile_position)
	return tile_id != null && tile_id.get_custom_data_by_layer_id(0)

func _ready() -> void:
	start_spawning()
