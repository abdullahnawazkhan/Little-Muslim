tool
extends Button

export var set_scene : PackedScene

func _on_button_up() -> void:
	PlayerData.score = 0
	PlayerData.deaths = 0
	get_tree().change_scene_to(set_scene)


func _get_configuration_warning() -> String:
	if not set_scene:
		return "The next scene property can't be empty"
	else:
		return ""
