extends Control


var saving_done = false


func _ready() -> void:
	$Timer.set_wait_time(1.0)
	$Timer.start()
	
#	"quest_in_progress" : {
#				"arrayValue" : {
#					"values" : []
#				}
#			},
	
	Firebase.user_data["health"]["integerValue"] = PlayerData.health
	Firebase.user_data["points"]["integerValue"] = PlayerData.score
	
	# getting quests completed for saving
	var new_comp_vals = []
	for i in range(len(PlayerData.quests_completed)):
		new_comp_vals.append({
			"stringValue" : PlayerData.quests_completed[i]
		})
	Firebase.user_data["quest_completed"]["arrayValue"]["values"] = new_comp_vals
	
	# getting quests in progress for saving
	var new_prog_vals = []
	for i in range(len(PlayerData.quests_in_progress)):
		new_prog_vals.append({
			"stringValue" : PlayerData.quests_in_progress[i]
		})
	Firebase.user_data["quest_in_progress"]["arrayValue"]["values"] = new_prog_vals
	
	# getting surahs/duas memorization in progress
	var new_memorizing_vals = []
	for i in range(len(PlayerData.memorizing)):
		new_memorizing_vals.append({
			"stringValue" : PlayerData.memorizing[i]
		})
	Firebase.user_data["dua_memorizing"]["arrayValue"]["values"] = new_memorizing_vals
	
	# getting surahs/memorizing memorized
	var new_memorized_vals = []
	for i in range(len(PlayerData.memorized)):
		new_memorized_vals.append({
			"stringValue" : PlayerData.memorized[i]
		})
	Firebase.user_data["dua_memorized"]["arrayValue"]["values"] = new_memorized_vals
	
	var save_date = Firebase.user_data
	Firebase.update_document("users/%s" % Firebase.user_id, save_date, $HTTPRequest)


func _physics_process(delta: float) -> void:
	if ($Timer.is_stopped() == true):
		if ($Label.text == "Saving..."):
			$Label.text = "Saving"
		else:
			$Label.text += "." 
		$Timer.set_wait_time(1.0)
		$Timer.start()


func _on_Timer_timeout() -> void:
	$Timer.stop()


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Saving Done")
		queue_free()
	else:
		var d = parse_json(body.get_string_from_utf8())
		var msg = d["error"]["message"]
		print(msg)
