extends Control

onready var loading_msg := get_node("element/loading_pane")
onready var error_pane := get_node("element/error_pane")
onready var error_msg := get_node("element/error_pane/popup/error_msg")
onready var success_pane := get_node("element/success_pane")
onready var email := get_node("element/email")
onready var password := get_node("element/password")


var keyboard_open = false


func _on_Button_button_up() -> void:
	loading_msg.visible = true
	
	Firebase.log_in($element/log_in_request, $element/email.text, $element/password.text)



func _on_log_in_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var response_data = parse_json(body.get_string_from_utf8())
		
		Firebase.user_token = response_data["idToken"]
		Firebase.user_id = response_data["localId"]
		
#		creating a new file
#		if file already exists, it will just open
#		else it will create a new one
		var file = File.new()
		file.open("user://save_login.dat", File.WRITE)
		
#		preparing data for file storage
		var save_data = $element/email.text + "/" + $element/password.text
		
#		saving data inside the file
		file.store_string(save_data)
		file.close()
		
		var document_path = "users/%s" % Firebase.user_id
		
		Firebase.get_document(document_path, $element/get_document_request)
	elif (response_code == 400):
		var response_data = parse_json(body.get_string_from_utf8())
		
		error_pane.visible = true
		loading_msg.visible = false
		
		if (response_data["error"]["message"] == "EMAIL_NOT_FOUND"):
			print("No Such Email exists")
			error_msg.text = "Incorrect Email Entered"
		elif (response_data["error"]["message"] == "INVALID_PASSWORD"):
			print("Incorrect Password Entered")
			error_msg.text = "Incorrect Password Entered"
		elif (response_data["error"]["message"] == "INVALID_EMAIL"):
			error_msg.text = "Incorrect Email Entered"
		
		print(response_data["error"]["message"])
	else:
		# TODO: Make server error toast here
		print("Server Error")


func _on_get_document_request_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var data = parse_json(body.get_string_from_utf8())
	Firebase.user_data = data["fields"]
	var response_data = data["fields"]
	
	# getting list of quests that are in progress
	if (len(response_data["quest_in_progress"]["arrayValue"]) != 0):
		var size_of_in_progress = len(response_data["quest_in_progress"]["arrayValue"]["values"])
		for i in range(size_of_in_progress):
			PlayerData.quests_in_progress.append(response_data["quest_in_progress"]["arrayValue"]["values"][i]["stringValue"])
	
	# getting list of quests that are completed
	if (len(response_data["quest_completed"]["arrayValue"]) != 0):
		var size_of_completed = len(response_data["quest_completed"]["arrayValue"]["values"])
		for i in range(size_of_completed):
			PlayerData.quests_completed.append(response_data["quest_completed"]["arrayValue"]["values"][i]["stringValue"])
		
	# getting dictionary (map) of surahs/duas currently memorizing
	# key: dua/surah  -> value: number of times user has receited
	if (len(response_data["memorizing"]["mapValue"]) != 0):
		var size_of_in_progress = len(response_data["memorizing"]["mapValue"]["fields"])
		var items = response_data["memorizing"]["mapValue"]["fields"]
		for i in items:
			PlayerData.memorizing[i] = items[i]["integerValue"]

	# getting list of surahs/duas memorized
	if (len(response_data["memorized"]["arrayValue"]) != 0):
		var size_of_completed = len(response_data["memorized"]["arrayValue"]["values"])
		for i in range(size_of_completed):
			PlayerData.memorized.append(response_data["memorized"]["arrayValue"]["values"][i]["stringValue"])

	PlayerData.set_health(int(response_data["health"]["integerValue"]))
	PlayerData.set_score(int(response_data["points"]["integerValue"]))
	PlayerData.user_level = (response_data["level"]["stringValue"])
	
	
	$element/namaz_timings.request("http://api.aladhan.com/v1/timingsByCity?city=Islamabad&country=Pakistan&method=8")


func _on_forgot_password_button_up() -> void:
	print("Forgot my password Button pressed")
	get_tree().change_scene("res://src/screens/log_in_module/forgot_password/forgot_password.tscn")


func _on_error_cancel_button_pressed() -> void:
	error_pane.visible = false


func _on_Timer_timeout() -> void:
	get_tree().change_scene("res://src/screens/main_menu.tscn")


func _on_email_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$element.rect_position.y -= 150

		$element/password.focus_mode = FOCUS_NONE


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


func _on_password_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$element.rect_position.y -= 250

		$element/email.focus_mode = FOCUS_NONE


func _on_namaz_timings_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var response_data = parse_json(body.get_string_from_utf8())
		
		for x in response_data["data"]["timings"]:
			if (x == "Fajr"):
				NamazTimings.todays_timings["Fajr"] = response_data["data"]["timings"]["Fajr"]
			elif (x == "Dhuhr"):
				NamazTimings.todays_timings["Dhuhr"] = response_data["data"]["timings"]["Fajr"]
			elif (x == "Asr"):
				NamazTimings.todays_timings["Asr"] = response_data["data"]["timings"]["Asr"]
			elif (x == "Maghrib"):
				NamazTimings.todays_timings["Maghrib"] = response_data["data"]["timings"]["Maghrib"]
			elif (x == "Isha"):
				NamazTimings.todays_timings["Isha"] = response_data["data"]["timings"]["Isha"]
		
	else:
		print("Server Error")
		
	success_pane.visible = true
	loading_msg.visible = false

	$element/Timer.set_wait_time(2.5)
	$element/Timer.start()
