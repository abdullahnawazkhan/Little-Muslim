extends Control


func _on_Button_button_up() -> void:
	print("Email Entered: " + $email.text)
	print("Password Entered: " + $password.text)
	
	var body = {
		"email" : $email.text,
		"password" : $password.text,
		"returnSecureToken" : true
	}
	
	Firebase.log_in($HTTPRequest, body)



func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Log in successful")
		var dict = parse_json(body.get_string_from_utf8())
		Firebase.user_token = dict["idToken"]
		Firebase.user_id = dict["localId"]
		$success_pane.visible = true
		Firebase.get_document("users/%s" % Firebase.user_id, $get_document_request)
	elif (response_code == 400):
		var dict = parse_json(body.get_string_from_utf8())
		$error_pane.visible = true
		if (dict["error"]["message"] == "EMAIL_NOT_FOUND"):
			print("No Such Email exists")
			$error_pane/popup/error_msg.text = "Incorrect Email Entered"
		elif (dict["error"]["message"] == "INVALID_PASSWORD"):
			print("Incorrect Password Entered")
			$error_pane/popup/error_msg.text = "Incorrect Password Entered"
		elif (dict["error"]["message"] == "INVALID_EMAIL"):
			$error_pane/popup/error_msg.text = "Incorrect Email Entered"
		print(dict["error"]["message"])
		$Timer.set_wait_time(3.0)
		$Timer.start()
	else:
		# TODO: Make server error toast here
		print("Server Error")


func _on_get_document_request_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var dict = parse_json(body.get_string_from_utf8())
	Firebase.user_data = dict["fields"]
	get_tree().change_scene("res://src/screens/main_menu.tscn")


func _on_Timer_timeout() -> void:
	$Timer.stop()
	$error_pane.visible = false
	$email.text = ""
	$password.text = ""
