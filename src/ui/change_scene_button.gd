tool
extends Button

export(String, FILE) var scene_path := ""

func _get_configuration_warning() -> String:
	if not scene_path:
		return "The next scene property can't be empty"
	else:
		return ""


func _on_change_scene_button_button_up() -> void:
	PlayerData.score = 0
	PlayerData.deaths = 0
	get_tree().paused = false
	get_tree().change_scene(scene_path)
