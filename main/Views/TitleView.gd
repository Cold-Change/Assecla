extends Control

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	get_tree().paused = false
	
func _on_start_pressed() -> void:
	@warning_ignore("unsafe_method_access")
	await LevelTransition.fade_to_black()
	get_tree().change_scene_to_file("res://World/Facility.tscn")
	@warning_ignore("unsafe_method_access")
	LevelTransition.fade_from_black()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_about_pressed() -> void:
	$MarginContainer/Panel.visible = true
