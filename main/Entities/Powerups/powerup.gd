extends Node2D
class_name Powerup

enum Rarity
{
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

@export var powerup_name:String
@export_multiline var description:String
@export var rarity:Rarity
@export var icon:Texture2D


var current_stack := 0
var parasite: Parasite

func _ready() -> void:
	parasite = get_parent()
	stack()

func stack() -> void:
	current_stack += 1
