extends Button

onready var ui := get_tree().get_current_scene().get_node("UserInterface/UserInterface")

func _on_ResumeButton_button_up() -> void:
	get_tree().paused = false
	ui.is_paused = false
