extends Control


func _on_TouchScreenButton_pressed() -> void:
	print("Back button pressed")
	get_tree().change_scene("res://src/screens/log_in_module/log_in/log_in.tscn")


func _on_Button_button_up() -> void:
	Firebase.forgot_my_password($LineEdit.text, $HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Email Sent")
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print("error sending email")
		
