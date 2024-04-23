extends Node2D
class_name Biomass

@export var textures:Array[Texture2D]
@export var xp_value := 1

func _ready() -> void:
	$Sprite2D.texture = textures.pick_random()
