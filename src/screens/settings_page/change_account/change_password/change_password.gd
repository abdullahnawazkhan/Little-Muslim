extends Control

var keyboard_open = false

func is_digit(s) -> bool:
	# ascii values between 30H and 39H inclusive are digits
	var ascii = int((s.to_ascii()).hex_encode())
	
	if ascii < 30 || ascii > 39:
		return false
		
	return true


func validate_password() -> bool:
	# checking if both passwords match
	if ($password_1.text != $password_2.text):
		$error_msg_area/Label.text = "Passwords Do Not Match"
		return false
	
	# Rules:
	#	- Password Must be atleast of length 8
	#	- Password Must contain atleast 1 digit
	if (len($password_1.text) < 8):
		$error_msg_area/Label.text = "Password must be of length 8"
		return false
	
	for i in range(len($password_1.text)):
		if (is_digit($password_1.text[i]) == true):
			return true
	
	$error_msg_area/Label.text = "Password must contain 1 digit"
	return false

func _on_Button_button_up() -> void:
	$loading.visible = true
	
	if (validate_password() == false):
		$loading.visible = false
		$error_msg_area.visible = true
	else:
		Firebase.change_password($password_1.text, $HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var dict = parse_json(body.get_string_from_utf8())
		Firebase.user_token = dict["idToken"]
		print("Password Changed")
		
		var file = File.new()
		file.open("user://save_login.dat", File.READ)
		var content = file.get_as_text()
		var arr = content.split("/")
		var email = arr[0]
		var password = arr[1]
		file.close()
		
		file.open("user://save_login.dat", File.WRITE)
		file.store_string(email + "/" + $password_1.text)
		file.close()
		
		$loading.visible = false
		$success_msg_area.visible = true
		
		
	else:
		var dict = parse_json(body.get_string_from_utf8())
		print("ERROR CHANGING PASSWORD")


func _on_error_cancel_button_pressed() -> void:
	$error_msg_area.visible = false


func _on_success_cancel_button_pressed() -> void:
	get_tree().change_scene("res://src/screens/settings_page/change_account/change_account_details.tscn")


func _on_password_1_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 150
		$elements/password_2.focus_mode = FOCUS_NONE
		
		
func _on_password_2_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 250
		$elements/password_1.focus_mode = FOCUS_NONE



func _process(delta: float) -> void:
	if OS.has_virtual_keyboard() == true:
		if OS.get_virtual_keyboard_height() > 0:
			keyboard_open = true
			
		if keyboard_open == true:
			if OS.get_virtual_keyboard_height() == 0:
				$elements.rect_position.y = 0
				keyboard_open = false

				$elements/password_1.release_focus()
				$elements/password_2.release_focus()
				
				$elements/password_2.focus_mode = FOCUS_ALL
				$elements/password_1.focus_mode = FOCUS_ALL
