extends Control

onready var user_name = get_node("elements/ScrollContainer/VBoxContainer/name_box/name")
onready var email = get_node("elements/ScrollContainer/VBoxContainer/email_box/email")
onready var password_1 = get_node("elements/ScrollContainer/VBoxContainer/password_1_box/password")
onready var password_2 = get_node("elements/ScrollContainer/VBoxContainer/password_2_box/password2")
onready var country_name = get_node("elements/ScrollContainer/VBoxContainer/country_box/country_name")
onready var city_name = get_node("elements/ScrollContainer/VBoxContainer/city_box/city_name")


var COUNTRY = preload("res://src/screens/settings_page/add_location/country_select/country.tscn")
var CITY = preload("res://src/screens/settings_page/add_location/city_select/city.tscn")

var country_code

var keyboard_open = false

func is_digit(s) -> bool:
	# ascii values between 30H and 39H inclusive are digits
	var ascii = s.to_ascii()
	var hex = int(ascii.hex_encode())
	
	if hex < 30 || hex > 39:
		return false
		
	return true


func validate_password() -> bool:
	# checking if both passwords match
	if (password_1.text != password_2.text):
		$elements/error_pane/ColorRect/error_msg.text = "Passwords Do Not Match"
		return false
	
	# Rules:
	#	- Password Must be atleast of length 8
	#	- Password Must contain atleast 1 digit
	if (len(password_1.text) < 8):
		$elements/error_pane/ColorRect/error_msg.text = "Password must be of length 8"
		return false
	
	# checking if password has atleast 1 digit
	for i in range(len(password_1.text)):
		var pass_text = password_1.text
		var character = pass_text[i]
		if (is_digit(character) == true):
			return true
	
	$elements/error_pane/ColorRect/error_msg.text = "Password must contain 1 digit"
	return false


func check_fill() -> bool:
	if password_1.text == "" || password_2.text == "" || user_name.text == "" || email.text == "" || country_name.text == "" || city_name.text == "":
		return false

	return true

func _on_Button_button_up() -> void:
	$elements/loading.visible = true
	
	# checking if all data has been entered
	if (check_fill() == false):
		$elements/error_pane/ColorRect/error_msg.text = "Please fill in all required data"
		$elements/error_pane.visible = true 
		$elements/loading.visible = false
	elif (validate_password() == false):
		$elements/error_pane.visible = true
		$elements/loading.visible = false
		
		print("Passwords do not match")
	else:
		Firebase.register($elements/account_creation, email.text, password_1.text)



func _on_account_creation_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Registration Completed")
		
		var d = parse_json(body.get_string_from_utf8())
		
		Firebase.user_id = d["localId"]
		Firebase.user_token = d["idToken"]
		
		print("Account Created")
		
		var dict = {
			"country": {
				"stringValue" : country_name.text
			},
			"city": {
				"stringValue" : city_name.text
			},
			"studdent"
			"name" : {
				"stringValue" : user_name.text
			},
			"memorized" : {
				"arrayValue" : {
					"values" : []
				}
			},
			"memorizing" : {
				"mapValue" : {
					"fields" : {}
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
			},
			"level" : {
				"stringValue" : "tutorial"
			}
		}
		
		Firebase.user_data = dict
		Firebase.save_document("users?documentId=%s" % Firebase.user_id, dict, $elements/document_creation)
	elif (response_code == 400):
		var d = parse_json(body.get_string_from_utf8())
		var msg = d["error"]["message"]
		
		$elements/loading.visible = false
		$elements/error_pane.visible = true
		
		if msg == "INVALID_EMAIL":
			$elements/error_pane/ColorRect/error_msg.text = "Invalid Email Entered"
			print("Invalid Email Entered")
		elif msg == "EMAIL_EXISTS":
			$elements/error_pane/ColorRect/error_msg.text = "Email is already in use"
			print("Email is already in use")
		
	else:
		# TODO: Add android toast here
		print("Server Error")


func _on_document_creation_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		$elements/success_pane.visible = true
		$elements/loading.visible = false
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print(dict["error"]["message"])


func _on_TouchScreenButton_pressed() -> void:
	get_tree().change_scene("res://src/screens/start_up_screen.tscn")


func _on_error_cancel_button_pressed() -> void:
	$elements/error_pane.visible = false


func _on_email_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 150
		
		$elements/name.focus_mode = FOCUS_NONE
		$elements/password.focus_mode = FOCUS_NONE
		$elements/password2.focus_mode = FOCUS_NONE


func _on_password_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 250
		
		$elements/name.focus_mode = FOCUS_NONE
		$elements/email.focus_mode = FOCUS_NONE
		$elements/password2.focus_mode = FOCUS_NONE


func _on_password2_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 350
		
		$elements/name.focus_mode = FOCUS_NONE
		$elements/email.focus_mode = FOCUS_NONE
		$elements/password.focus_mode = FOCUS_NONE


func _process(delta: float) -> void:
	if OS.has_virtual_keyboard() == true:
		if OS.get_virtual_keyboard_height() > 0:
			keyboard_open = true
			
		if keyboard_open == true:
			if OS.get_virtual_keyboard_height() == 0:
				$elements.rect_position.y = 0
				keyboard_open = false
				
				$elements/email.release_focus()
				$elements/name.release_focus()
				$elements/password.release_focus()
				$elements/password2.release_focus()
				
				$elements/password2.focus_mode = FOCUS_ALL
				$elements/email.focus_mode = FOCUS_ALL
				$elements/password.focus_mode = FOCUS_ALL
				$elements/name.focus_mode = FOCUS_ALL


func _on_name_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements/password2.focus_mode = FOCUS_NONE
		$elements/email.focus_mode = FOCUS_NONE
		$elements/password.focus_mode = FOCUS_NONE


func set_country(country_text, country_code_value):
	country_name.text = country_text
	country_code = country_code_value
	

func set_city(city_text):
	city_name.text = city_text


func _on_select_country_button_up() -> void:
	var country = COUNTRY.instance()
	self.add_child(country)


func _on_select_city_button_up() -> void:
	var city = CITY.instance()
	city.set_id(country_code)
	self.add_child(city)


func _on_students_text_entered(new_text: String) -> void:
	pass # Replace with function body.
