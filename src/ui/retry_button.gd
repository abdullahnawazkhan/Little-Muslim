extends Button

func _on_button_up() -> void:
	PlayerData.health = 100
	PlayerData.score = 0
	get_tree().paused = false
	get_tree().change_scene("res://src/screens/loading_screen.tscn")