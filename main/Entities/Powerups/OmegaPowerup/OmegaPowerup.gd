extends Powerup

func _ready() -> void:
	super()
	parasite.on_enemy_controlled.connect(_on_heal)

func stack() -> void:
	current_stack += 1

func _on_heal() -> void:

	parasite.heal(current_stack + 1)
	DamageNumbersServer.go_heal(current_stack, parasite.global_position)
