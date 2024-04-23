extends Control
class_name GameOverView

@export var enemies_killed_label:Label
@export var enemies_possessed_label:Label
@export var powerups_gained_label:Label
@export var time_survived_label:Label

func transition_on() -> void:
	get_tree().paused = true
	visible = true
	
func set_model(parasite:Parasite):
	enemies_killed_label.text = "Enemies Killed: " + str(parasite.get_enemy_kills())
	enemies_possessed_label.text = "Enemies Posessed: " + str(parasite.get_enemy_posessed())
	powerups_gained_label.text = "Powerups Gained: " + str(parasite.get_powerup_count())
	time_survived_label.text = "Time Survived: " + str(parasite.get_time_survived())


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Views/TitleView.tscn")
