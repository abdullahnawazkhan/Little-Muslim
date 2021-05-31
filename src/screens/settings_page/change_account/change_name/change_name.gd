extends Control

var keyboard_open = false

func _on_Button_button_up() -> void:
	$elements/loading.visible = true
	
	var new_profile_data = Firebase.user_data
	new_profile_data["name"]["stringValue"] = $elements/name.text
	
	Firebase.update_document("users/%s" % Firebase.user_id, new_profile_data, $elements/HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	$elements/success_pane.visible = true
	$elements/loading.visible = false
	if (response_code == 200):
		print("Name updated")
		Firebase.user_data["name"]["stringValue"] = $elements/name.text
	else:
		print("ERROR in updating name")


func _on_TouchScreenButton_pressed() -> void:
	get_tree().change_scene("res://src/screens/settings_page/change_account/change_account_details.tscn")


func _on_name_focus_entered() -> void:
	if OS.has_virtual_keyboard() == true:
		$elements.rect_position.y -= 200
	

func _process(delta: float) -> void:
	if OS.has_virtual_keyboard() == true:
		if OS.get_virtual_keyboard_height() > 0:
			keyboard_open = true
			
		if keyboard_open == true:
			if OS.get_virtual_keyboard_height() == 0:
				$elements.rect_position.y = 0
				keyboard_open = false
				$elements/name.release_focus()

