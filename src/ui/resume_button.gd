extends Button

onready var ui := get_tree().get_current_scene().get_node("user_interface/user_interface")


func _on_button_up() -> void:
	ui.is_paused = false
	get_tree().paused = false
