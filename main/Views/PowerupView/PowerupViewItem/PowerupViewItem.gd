extends Control
class_name PowerupItemView

@export var name_label:Label
@export var description_label:Label
@export var texture_rect:TextureRect

@export var panel:Panel

var current:Powerup

signal on_powerup_selected(powerup: Powerup)

var color_from_rarity:Dictionary = {
	Powerup.Rarity.COMMON : Color.WHITE,
	Powerup.Rarity.UNCOMMON : Color.DARK_GREEN,
	Powerup.Rarity.RARE : Color.ROYAL_BLUE,
	Powerup.Rarity.EPIC : Color.REBECCA_PURPLE,
	Powerup.Rarity.LEGENDARY : Color.GOLDENROD
}

func set_model(powerup:Powerup) -> void:
	name_label.text = powerup.powerup_name	
	description_label.text = powerup.description
	texture_rect.texture = powerup.icon
	current = powerup
	var styleBox:StyleBox = panel.get("theme_override_styles/panel")
	var newStyle:StyleBox = styleBox.duplicate()
	newStyle.border_color = color_from_rarity[powerup.rarity]
	
	panel.set("theme_override_styles/panel", newStyle)
	


func _on_gui_input(event: InputEvent) -> void:
	var input_event_mouse_button := event as InputEventMouseButton
	if input_event_mouse_button != null && input_event_mouse_button.button_index == 1:
		on_powerup_selected.emit(current)
