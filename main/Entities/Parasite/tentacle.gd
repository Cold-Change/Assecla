extends Line2D
class_name Tentacle

@export var reach_speed := 3000.0

@export var return_speed := 2000.0

@onready var state_chart:StateChart = $StateChart
var possess_enemy:Callable

var target_enemy:Enemy

var is_idle: = false

func _ready() -> void:
	assert(possess_enemy, "possess_enemy isn't set")

func set_target_enemy(enemy: Enemy) -> void:
	target_enemy = enemy
	target_enemy.on_death.connect(enemy_died)
	state_chart.send_event("reach")

func enemy_died(_enemy: Enemy) -> void:
	target_enemy = null

func _on_reaching_state_physics_processing(delta: float) -> void:
	if !is_instance_valid(target_enemy):
		state_chart.send_event("return")
		return
		
	var last_point := points[0]
	last_point += to_global(last_point).direction_to(target_enemy.global_position) * reach_speed * delta
	if last_point.length_squared() > to_local(target_enemy.global_position).length_squared():
		last_point = to_local(target_enemy.global_position)
		if possess_enemy.call(target_enemy) == true:
			state_chart.send_event("hold_enemy")
		else:
			state_chart.send_event("hurt")
			target_enemy.on_death.disconnect(enemy_died)
			target_enemy = null
		
	set_point_position(0, last_point)

func _on_hurt_state_entered() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:v", 1, 0.25).from(15)

func _on_hurt_state_exited() -> void:
	pass # Replace with function body.

func _on_return_state_physics_processing(delta: float) -> void:
	var last_point := points[0]
	var curr_point := last_point
	last_point -= last_point.normalized() * reach_speed * delta
	if reach_speed * delta >= curr_point.length():
		last_point = Vector2.ZERO
		state_chart.send_event("idle")
		
	set_point_position(0, last_point)

func _on_holding_enemy_state_physics_processing(_delta: float) -> void:
	if !is_instance_valid(target_enemy):
		state_chart.send_event("return")
		return
	set_point_position(0, to_local(target_enemy.global_position))

func _on_idle_state_entered() -> void:
	is_idle = true

func _on_idle_state_exited() -> void:
	is_idle = false
