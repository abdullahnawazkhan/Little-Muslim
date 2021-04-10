extends Control


func validate_password() -> bool:
	# TODO: Add password requirements here
	if ($password.text == $password2.text):
		return true
	else:
		return false


func _on_Button_button_up() -> void:
	if (validate_password() == false):
		# show error msg here
		$error_pane.visible = true
		$error_pane/ColorRect/error_msg.text = "Passwords Do Not Match"
		$Timer.set_wait_time(3.0)
		$Timer.start()
		print("Passwords do not match")
	else:
		var body = {
			"email" : $email.text,
			"password" : $password.text,
		}
		
		Firebase.register($account_creation, body)
#		$RichTextLabel.text = "Processing"



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
			}
		}
		
		Firebase.user_data = dict
		$success_pane.visible = true
		Firebase.save_document("users?documentId=%s" % Firebase.user_id, dict, $document_creation)
	elif (response_code == 400):
		var d = parse_json(body.get_string_from_utf8())
		var msg = d["error"]["message"]
		$error_pane.visible = true
		if msg == "INVALID_EMAIL":
			$error_pane/ColorRect/error_msg.text = "Invalid Email Entered"
			print("Invalid Email Entered")
		elif msg == "EMAIL_EXISTS":
			$error_pane/ColorRect/error_msg.text = "Email is already in use"
			print("Email is already in use")
			
		$Timer.set_wait_time(3.0)
		$Timer.start()
		
	else:
		# TODO: Add android toast here
		print("Server Error")


func _on_document_creation_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Document Created")
		get_tree().change_scene("res://src/screens/start_up_screen.tscn")
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print(dict["error"]["message"])
#		$RichTextLabel.text = dict["error"]["message"]


func _on_Timer_timeout() -> void:
	$Timer.stop()
	$error_pane.visible = false
