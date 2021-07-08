extends Control


func _ready() -> void:
	InternetConnection.in_game = false


func _on_log_out_button_up() -> void:
	# showing the confirmation dialog
	$confirmation_dialog.visible = true


func _on_yes_button_released() -> void:
	# when logging out
	# need to remove login save data file
	# so that autologin does not log user in again
	var dir = Directory.new()
	dir.remove("user://save_login.dat")
	get_tree().change_scene("res://src/screens/start_up_screen.tscn")


func _on_no_button_released() -> void:
	$confirmation_dialog.visible = false
