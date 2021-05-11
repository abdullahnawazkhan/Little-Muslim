extends Control

onready var loading_msg := get_node("loading")
onready var error_pane := get_node("error_pane")
onready var error_msg := get_node("error_pane/popup/error_msg")
onready var success_pane := get_node("success_pane")


func _on_Button_button_up() -> void:
	loading_msg.visible = true
	
	print("Email Entered: " + $email.text)
	print("Password Entered: " + $password.text)
	
	Firebase.log_in($HTTPRequest, $email.text, $password.text)



func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var dict = parse_json(body.get_string_from_utf8())
		
		Firebase.user_token = dict["idToken"]
		Firebase.user_id = dict["localId"]
		
		Firebase.get_document("users/%s" % Firebase.user_id, $get_document_request)
	elif (response_code == 400):
		var dict = parse_json(body.get_string_from_utf8())
		
		error_pane.visible = true
		loading_msg.visible = false
		
		if (dict["error"]["message"] == "EMAIL_NOT_FOUND"):
			print("No Such Email exists")
			error_msg.text = "Incorrect Email Entered"
		elif (dict["error"]["message"] == "INVALID_PASSWORD"):
			print("Incorrect Password Entered")
			error_msg.text = "Incorrect Password Entered"
		elif (dict["error"]["message"] == "INVALID_EMAIL"):
			error_msg.text = "Incorrect Email Entered"
		
		print(dict["error"]["message"])
	else:
		# TODO: Make server error toast here
		print("Server Error")


func _on_get_document_request_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var dict = parse_json(body.get_string_from_utf8())
	Firebase.user_data = dict["fields"]
	var d = dict["fields"]
	
	var file = File.new()
	file.open("user://save_login.dat", File.WRITE)
	var save_data = $email.text + "/" + $password.text
	file.store_string(save_data)
	file.close()
	
	# getting list of quests that are in progress
	if (len(d["quest_in_progress"]["arrayValue"]) != 0):
		var size_of_in_progress = len(d["quest_in_progress"]["arrayValue"]["values"])
		for i in range(size_of_in_progress):
			PlayerData.quests_in_progress.append(d["quest_in_progress"]["arrayValue"]["values"][i]["stringValue"])
	
	# getting list of quests that are completed
	if (len(d["quest_completed"]["arrayValue"]) != 0):
		var size_of_completed = len(d["quest_completed"]["arrayValue"]["values"])
		for i in range(size_of_completed):
			PlayerData.quests_completed.append(d["quest_completed"]["arrayValue"]["values"][i]["stringValue"])
		
	# getting list of surahs/duas currently memorizing
	if (len(d["dua_memorizing"]["arrayValue"]) != 0):
		var size_of_in_progress = len(d["dua_memorizing"]["arrayValue"]["values"])
		for i in range(size_of_in_progress):
			PlayerData.memorizing.append(d["dua_memorizing"]["arrayValue"]["values"][i]["stringValue"])

	# getting list of surahs/duas memorized
	if (len(d["dua_memorized"]["arrayValue"]) != 0):
		var size_of_completed = len(d["dua_memorized"]["arrayValue"]["values"])
		for i in range(size_of_completed):
			PlayerData.memorized.append(d["dua_memorized"]["arrayValue"]["values"][i]["stringValue"])

	PlayerData.set_health(int(d["health"]["integerValue"]))
	PlayerData.set_score(int(d["points"]["integerValue"]))
	
	success_pane.visible = true
	loading_msg.visible = false


func _on_forgot_password_button_up() -> void:
	print("Forgot my password Button pressed")
	get_tree().change_scene("res://src/screens/log_in_module/forgot_password/forgot_password.tscn")


func _on_success_cancel_button_pressed() -> void:
	get_tree().change_scene("res://src/screens/main_menu.tscn")


func _on_error_cancel_button_pressed() -> void:
	error_pane.visible = false
