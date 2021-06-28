extends Control

onready var loading_msg := get_node("element/loading")
onready var error_pane := get_node("element/error_pane")
onready var error_msg := get_node("element/error_pane/popup/error_msg")
onready var success_pane := get_node("element/success_pane")


var keyboard_open = false


func _on_Button_button_up() -> void:
	loading_msg.visible = true
	
	print("Email Entered: " + $element/email.text)
	print("Password Entered: " + $element/password.text)
	
	Firebase.log_in($element/HTTPRequest, $element/email.text, $element/password.text)



func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var dict = parse_json(body.get_string_from_utf8())
		
		Firebase.user_token = dict["idToken"]
		Firebase.user_id = dict["localId"]
		
		Firebase.get_document("users/%s" % Firebase.user_id, $element/get_document_request)
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
	var save_data = $element/email.text + "/" + $element/password.text
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
		
	# getting dictionary (map) of surahs/duas currently memorizing
	# key: dua/surah  -> value: number of times user has receited
	if (len(d["memorizing"]["mapValue"]) != 0):
		var size_of_in_progress = len(d["memorizing"]["mapValue"]["fields"])
		var items = d["memorizing"]["mapValue"]["fields"]
		for i in items:
			PlayerData.memorizing[i] = items[i]["integerValue"]

	# getting list of surahs/duas memorized
	if (len(d["memorized"]["arrayValue"]) != 0):
		var size_of_completed = len(d["memorized"]["arrayValue"]["values"])
		for i in range(size_of_completed):
			PlayerData.memorized.append(d["memorized"]["arrayValue"]["values"][i]["stringValue"])

	PlayerData.set_health(int(d["health"]["integerValue"]))
	PlayerData.set_score(int(d["points"]["integerValue"]))
	
	
	$element/namaz_timings.request("http://api.aladhan.com/v1/timingsByCity?city=Islamabad&country=Pakistan&method=8")


func _on_forgot_password_button_up() -> void:
	print("Forgot my password Button pressed")
	get_tree().change_scene("res://src/screens/log_in_module/forgot_password/forgot_password.tscn")


func _on_error_cancel_button_pressed() -> void:
	error_pane.visible = false


func _on_Timer_timeout() -> void:
	get_tree().change_scene("res://src/screens/main_menu.tscn")


#func _on_email_focus_entered() -> void:
#	if OS.has_virtual_keyboard() == true:
#		$element.rect_position.y -= 150
#
#		$element/password.focus_mode = FOCUS_NONE


func _process(delta: float) -> void:
	if OS.has_virtual_keyboard() == true:
		if OS.get_virtual_keyboard_height() > 0:
			keyboard_open = true
			
		if keyboard_open == true:
			if OS.get_virtual_keyboard_height() == 0:
				$element.rect_position.y = 0
				keyboard_open = false
				$element/email.release_focus()
				$element/password.release_focus()
				
				$element/password.focus_mode = FOCUS_ALL
				$element/email.focus_mode = FOCUS_ALL


#func _on_password_focus_entered() -> void:
#	if OS.has_virtual_keyboard() == true:
#		$element.rect_position.y -= 250
#
#		$element/email.focus_mode = FOCUS_NONE


func _on_namaz_timings_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var dict = parse_json(body.get_string_from_utf8())
		
		for x in dict["data"]["timings"]:
			if (x == "Fajr"):
				NamazTimings.todays_timings["Fajr"] = dict["data"]["timings"]["Fajr"]
			elif (x == "Dhuhr"):
				NamazTimings.todays_timings["Dhuhr"] = dict["data"]["timings"]["Fajr"]
			elif (x == "Asr"):
				NamazTimings.todays_timings["Asr"] = dict["data"]["timings"]["Asr"]
			elif (x == "Maghrib"):
				NamazTimings.todays_timings["Maghrib"] = dict["data"]["timings"]["Maghrib"]
			elif (x == "Isha"):
				NamazTimings.todays_timings["Isha"] = dict["data"]["timings"]["Isha"]
		
	else:
		print("Server Error")
		
	success_pane.visible = true
	loading_msg.visible = false

	$element/Timer.set_wait_time(2.5)
	$element/Timer.start()
