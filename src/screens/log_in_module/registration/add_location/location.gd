extends Control

var country_code

var COUNTRY = preload("res://src/screens/settings_page/add_location/country_select/country.tscn")
var CITY = preload("res://src/screens/settings_page/add_location/city_select/city.tscn")

var done_location : String


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
		queue_free()
	else:
		print("Error")
