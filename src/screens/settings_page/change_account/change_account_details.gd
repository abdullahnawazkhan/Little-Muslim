extends Control


func _on_log_out_button_up() -> void:
	var dir = Directory.new()
	dir.remove("user://save_login.dat")
	get_tree().change_scene("res://src/screens/start_up_screen.tscn")


func _on_reset_data_request_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	$loading.visible = false
	$success.visible = true


func _on_Button_button_up() -> void:
	$confirmation_dialog.visible = true



func _on_success_cancel_button_pressed() -> void:
	$success.visible = false


func _on_yes_button_released() -> void:
	var dict = {
		"name" : {
			"stringValue" : Firebase.user_data["name"]["stringValue"]
		},
		"dua_memorized" : {
			"arrayValue" : {
				"values" : []
			}
		},
		"dua_memorizing" : {
			"arrayValue" : {
				"values" : []
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
		}
	}
	
	Firebase.update_document("users/%s" % Firebase.user_id, dict, $reset_data_request)\
	
	$confirmation_dialog.visible = false
	$loading.visible = true


func _on_no_button_released() -> void:
	$confirmation_dialog.visible = false
