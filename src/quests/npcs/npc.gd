extends Node

class_name npc


onready var ui := get_tree().get_current_scene().get_node("user_interface/user_interface")

var dialog = {}
var state = "000"
var curr_choices = {}
var save_data = {}


# child class will need to pass in values in the below variables
# values will be passed in the child's _ready() function

# will hold quest name for getting .json files
var quest_name
# this will be the start state of quest when it's "in_progress"
var in_progress_state


func _init(q_name, state) -> void:
	quest_name = q_name
	in_progress_state = state

	load_json()

	if "quest_1" in save_data["completed"]:
		queue_free()


func load_json() -> void:
	# loading dialog .json for the quest
	var file  = File.new()
	var error = file.open("res://src/quests/dialogs/" + quest_name + ".json", File.READ)
	if error == OK:
		dialog = parse_json(file.get_as_text())
		print("No issues loading JSON")
		file.close()
	else:
		print("Error loading JSON")

	# loading user save data
	# TODO: move this is to autoload
	var f2 = File.new()
	var e2 = f2.open("res://src/quests/dialogs/current_quests.json", File.READ)
	if e2 == OK:
		print("No Issue loading save file")
		save_data = parse_json(f2.get_as_text())
		var quests = save_data["in_progress"]
		state = "000"
		for q in quests:
			if q == quest_name:
				state = in_progress_state
		f2.close()
	else:
		print("Error loading save file")


func execute() -> void:
	if (state == "null"):
		# this is when there are no further transistions
		ui.dialog_end()
	elif(state == "finished"):
		# this is when the quest is finished
		# TODO: need to link quranic ayat/hadith to finish
		ui.dialog_end()
		_add_to_finished()
		queue_free()
	elif(dialog[state]["type"] == "quest_accepted_dialog"):
		# this is when user accepts the quest
		
		# adding the mission to user save data
		_add_to_in_progress()
		
		# setting dialog text and hiding choices window
		ui.hide_choices()
		ui.set_text(dialog[state]["text"])
		state = dialog[state]["next"]
	else:
		# there will be 2 types of dialogues here:
		#	- dialog which does not require user input ("dialog")
		#	- dialog which does require user input ("responses")
		if (dialog[state]["type"] == "dialog"):
			ui.hide_choices()
			ui.set_text(dialog[state]["text"])
			state = dialog[state]["next"]
		else:
			ui.set_text(dialog[state]["text"])
			curr_choices = dialog[state]["responses"]

			ui.generate_choices(curr_choices.keys())


func _add_to_in_progress() -> void:
	if !(quest_name in save_data["in_progress"]):
		(save_data["in_progress"]).append(quest_name)
		var file = File.new()
		var error = file.open("res://src/quests/dialogs/current_quests.json", File.WRITE)
		if error == OK:
			file.store_string(to_json(save_data))
			file.close()


func process_choice(choice) -> void:
	state = curr_choices[choice]
	execute()


func _add_to_finished() -> void:
	# removing current quest from "in_progress"
	if len(save_data["in_progress"]) == 1:
		save_data["in_progress"].clear()
	else:
		(save_data["in_progress"]).remove(quest_name)
		
	# adding current quest to "completed"
	save_data["completed"].append(quest_name)
	
	# updated values in file
	var file = File.new()
	var error = file.open("res://src/quests/dialogs/current_quests.json", File.WRITE)
	if error == OK:
		file.store_string(to_json(save_data))
	else:
		print("Error in saving to save file")
		
	file.close()


func init() -> void:
	pass
