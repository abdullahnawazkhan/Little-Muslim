extends Control


func validate_passwords() -> bool:
	if ($password_1.text == $password_2.text):
		return true
	else:
		return false

func _on_Button_button_up() -> void:
	if (validate_passwords() == false):
		print("Passwords do not Match")
		# TODO: SHOW POP UP HERE
	else:
		Firebase.change_password($password_1.text, $HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var dict = parse_json(body.get_string_from_utf8())
		Firebase.user_token = dict["idToken"]
		print("Password Changed")
		
		var file = File.new()
		file.open("user://save_login.dat", File.READ)
		var content = file.get_as_text()
		var arr = content.split("/")
		var email = arr[0]
		var password = arr[1]
		file.close()
		
		file.open("user://save_login.dat", File.WRITE)
		file.store_string(email + "/" + $password_1.text)
		file.close()
		
		get_tree().change_scene("res://src/screens/settings_page/change_account/change_account_details.tscn")
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print("ERROR CHANGING PASSWORD")
