extends Control
class_name PowerupView

var powerup_registry:PowerupRegistry = PowerupRegistry.new()
var powerup_item_view:PackedScene = preload("res://Views/PowerupView/PowerupViewItem/PowerupViewItem.tscn")
signal on_powerup(powerup: Powerup)

@export var item_parent:Control

static var instance:PowerupView

func _init() -> void:
	instance = self

func TransitionOn() -> void:
	get_tree().paused = true
	visible = true
	for i in item_parent.get_children():
		i.queue_free()
	
	for i in range(3):
		var new_item:Powerup = powerup_registry.get_random_instance()
		var new_item_view:PowerupItemView = powerup_item_view.instantiate()
		new_item_view.set_model(new_item)
		new_item_view.on_powerup_selected.connect(on_powerup_selected)
		item_parent.add_child(new_item_view)
	
func TransitionOff() -> void:
	visible = false
	get_tree().paused = false

func on_powerup_selected(powerup:Powerup) -> void:
	on_powerup.emit(powerup)
	TransitionOff()
