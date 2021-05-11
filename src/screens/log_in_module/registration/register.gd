extends Control

func is_digit(s) -> bool:
	# ascii values between 30H and 39H inclusive are digits
	var ascii = int((s.to_ascii()).hex_encode())
	
	if ascii < 30 || ascii > 39:
		return false
		
	return true


func validate_password() -> bool:
	# checking if both passwords match
	if ($password.text != $password2.text):
		$error_pane/ColorRect/error_msg.text = "Passwords Do Not Match"
		return false
	
	# Rules:
	#	- Password Must be atleast of length 8
	#	- Password Must contain atleast 1 digit
	if (len($password.text) < 8):
		$error_pane/ColorRect/error_msg.text = "Password must be of length 8"
		return false
	
	for i in range(len($password.text)):
		if (is_digit($password.text[i]) == true):
			return true
	
	$error_pane/ColorRect/error_msg.text = "Password must contain 1 digit"
	return false


func _on_Button_button_up() -> void:
	$loading.visible = true
	
	if (validate_password() == false):
		$error_pane.visible = true
		$loading.visible = false
		
		print("Passwords do not match")
	else:
		Firebase.register($account_creation, $email.text, $password.text)



func _on_account_creation_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Log in successful")
		
		var d = parse_json(body.get_string_from_utf8())
		
		Firebase.user_id = d["localId"]
		Firebase.user_token = d["idToken"]
		
		print("Account Created")
		
		var dict = {
			"name" : {
				"stringValue" : $name.text
			},
			"dua_memorized" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"dua_memorizing" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"inventory" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"quest_in_progress" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"quest_completed" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"health" : {
				"integerValue" : 100
			},
			"points" : {
				"integerValue" : 0  
			}
		}
		
		Firebase.user_data = dict
		Firebase.save_document("users?documentId=%s" % Firebase.user_id, dict, $document_creation)
	elif (response_code == 400):
		var d = parse_json(body.get_string_from_utf8())
		var msg = d["error"]["message"]
		
		$loading.visible = false
		$error_pane.visible = true
		
		if msg == "INVALID_EMAIL":
			$error_pane/ColorRect/error_msg.text = "Invalid Email Entered"
			print("Invalid Email Entered")
		elif msg == "EMAIL_EXISTS":
			$error_pane/ColorRect/error_msg.text = "Email is already in use"
			print("Email is already in use")
		
	else:
		# TODO: Add android toast here
		print("Server Error")


func _on_document_creation_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		$success_pane.visible = true
		$loading.visible = false
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print(dict["error"]["message"])


func _on_TouchScreenButton_pressed() -> void:
	get_tree().change_scene("res://src/screens/start_up_screen.tscn")


func _on_error_cancel_button_pressed() -> void:
	$error_pane.visible = false
