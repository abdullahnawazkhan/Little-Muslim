tool
extends TouchScreenButton


export(String, FILE) var scene_path := ""

func _get_configuration_warning() -> String:
	if not scene_path:
		return "The next scene property can't be empty"
	else:
		return ""


func _on_back_pressed() -> void:
	get_tree().change_scene(scene_path)


