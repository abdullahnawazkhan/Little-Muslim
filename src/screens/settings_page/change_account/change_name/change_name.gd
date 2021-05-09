extends Control


func _on_Button_button_up() -> void:
	var new_profile_data = Firebase.user_data
	new_profile_data["name"]["stringValue"] = $name.text
	
	Firebase.update_document("users/%s" % Firebase.user_id, new_profile_data, $HTTPRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	# TODO : SHOW POP UP
	if (response_code == 200):
		print("Name updated")
		Firebase.user_data["name"]["stringValue"] = $name.text
		get_tree().change_scene("res://src/screens/settings_page/change_account/change_account_details.tscn")
	else:
		print("ERROR in updating name")
