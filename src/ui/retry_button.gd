extends Button

func _on_button_up() -> void:
	get_tree().paused = false
	get_tree().change_scene("res://src/screens/loading_screen.tscn")
