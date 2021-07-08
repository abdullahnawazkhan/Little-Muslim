extends Control

func _ready() -> void:
	# used to adding a dot to the loading text after every 1 second
	$Timer.set_wait_time(1.0)
	$Timer.start()
	_check_existing_login()
	
	
func _check_existing_login() -> void:
	# the function will check 
	
	var file = File.new()
	if (file.file_exists("user://save_login.dat") == false):
		get_tree().change_scene("res://src/screens/start_up_screen.tscn")
	else:
		# automatically logs user in
		file.open("user://save_login.dat", File.READ)
		var content = file.get_as_text()
		# abc@xyz.com/Abc12345
		var arr = content.split("/")
		# arr [0] = left portion
		# arr [1] = right portion
		var email = arr[0]
		var password = arr[1]
		
		Firebase.log_in($auto_login, email, password)
	

func _physics_process(delta: float) -> void:
	if ($Timer.is_stopped() == true):
		if ($Label.text == "Loading..."):
			$Label.text = "Loading"
		else:
			$Label.text += "." 
		$Timer.set_wait_time(1.0)
		$Timer.start()


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Log in successful")
		var dict = parse_json(body.get_string_from_utf8())
		Firebase.user_token = dict["idToken"]
		Firebase.user_id = dict["localId"]
		Firebase.get_document("users/%s" % Firebase.user_id, $get_document)
	else:
		var dir = Directory.new()
		dir.remove("user://save_login.dat")
		
		get_tree().change_scene("res://src/screens/start_up_screen.tscn")
		


func _on_get_document_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
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
			
	# getting user country and city
	var city = response_data["city"]["stringValue"]
	var country = response_data["country"]["stringValue"]

	PlayerData.set_health(int(response_data["health"]["integerValue"]))
	PlayerData.set_score(int(response_data["points"]["integerValue"]))
	PlayerData.user_level = (response_data["level"]["stringValue"])
	
	$namaz_timings.request("http://api.aladhan.com/v1/timingsByCity?city=" + city + "&country=" + country + "&method=8")


func _on_Timer_timeout() -> void:
	$Timer.stop()


func _on_namaz_timings_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var d = parse_json(body.get_string_from_utf8())
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
		
	get_tree().change_scene("res://src/screens/main_menu.tscn")
