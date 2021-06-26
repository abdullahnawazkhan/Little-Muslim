extends Area2D

var UI

var learning_state = preload("res://src/memorization/learning/Control.tscn")
var testing_state = preload("res://src/memorization/testing/Control.tscn")


var data = {}

var surah_title
var surah
var ayat

var state
var state_obj


func _ready() -> void:
	UI = get_tree().get_current_scene().get_node("user_interface").get_node("user_interface")
	
	load_json()
	select_random()
	
	# checking if user has any elements in memorized array
	if len(PlayerData.memorized) == 0:
		state_obj = learning_state.instance()
	else:
		# selecting from random selected state
		if state == 0:
			state_obj = learning_state.instance()
		else:
			state_obj = testing_state.instance()

	state_obj = learning_state.instance()
		
	state_obj.init(surah_title, surah, ayat)
	state_obj.connect("recitation_done", self, "process")


func load_json() -> void:
	var file  = File.new()
	var error = file.open("res://src/memorization/memorization_list.json", File.READ)
	if error == OK:
		data = parse_json(file.get_as_text())
		print("No issues loading JSON")
		file.close()
	else:
		print("Error loading JSON")


func select_random() -> void:
	var rand = RandomNumberGenerator.new()
	rand.randomize()
	
	# getting random state [learning/testing]
	# state = 0  -> learning
	# state = 1  -> testing
	state = rand.randi_range(0, 1)
	
	# getting random surah/dua from list
	var random_number = str(rand.randi_range(1, 8))

	surah_title = data[random_number]['title']
	surah = data[random_number]['surah']
	ayat = data[random_number]['ayat']


func _on_Node2D_body_entered(body: Node) -> void:
	if (body.name == "player"):
#		UI.loading(true)
		UI.add_child(state_obj)
		get_tree().paused = true
		


func process(var option) -> void:
#	states:
#		0 --> Processing Memorizing
#		1 --> No processing
#		2 --> Processing Memorized
	if option == 0:
		if surah in PlayerData.memorizing:
			# incrementing count
			PlayerData.memorizing[surah] = int(PlayerData.memorizing[surah]) + 1
			# if count is greater than 10, removing from "memorizing" and moving to "memorized"
			if PlayerData.memorizing[surah] == 10:
				PlayerData.memorized.append(surah)
				PlayerData.memorizing.erase(surah)
		else:
			# adding surah to "memorizing"
			PlayerData.memorizing[surah] = 1
	elif option == 2:
		PlayerData.memorized.erase(surah)
		PlayerData.memorizing[surah] = 1
 
	get_tree().paused = false
	queue_free()
