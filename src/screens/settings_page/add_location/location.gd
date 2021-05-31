extends Control

var country_code

var COUNTRY = preload("res://src/screens/settings_page/add_location/country_select/country.tscn")
var CITY = preload("res://src/screens/settings_page/add_location/city_select/city.tscn")

var done_location : String


func _ready() -> void:
	$country.text = Firebase.user_data["country"]["stringValue"]
	$city.text = Firebase.user_data["city"]["stringValue"]


func set_done_location(loc : String) -> void:
	done_location = loc


func _on_select_country_pressed() -> void:
	var country = COUNTRY.instance()
	self.add_child(country)


func set_country(name, code) -> void:
	$country.text = name
	country_code = code
#	print(code)


func _on_select_city_pressed() -> void:
	var city = CITY.instance()
	city.set_id(country_code)
	self.add_child(city)


func set_city(name) -> void:
	$city.text = name


func _on_continue_button_up() -> void:
	$pause_overlay.visible = true
	
	Firebase.user_data["country"]["stringValue"] = $country.text
	Firebase.user_data["city"]["stringValue"] = $city.text
	
	var save_date = Firebase.user_data
	
	Firebase.update_document("users/%s" % Firebase.user_id, save_date, $HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Account Creation Successful")
		$get_new_timings.request("http://api.aladhan.com/v1/timingsByCity?city=" + $city.text + "&country=" + $country.text + "&method=8")
	else:
		print("Error")


func _on_close_button_pressed() -> void:
	$success_overlay.visible = false


func _on_back_button_pressed() -> void:
	get_tree().change_scene("res://src/screens/settings_page/settings.tscn")


func _on_get_new_timings_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
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
		
		$pause_overlay.visible = false
		$success_overlay.visible = true
	else:
		print("Server Error")
