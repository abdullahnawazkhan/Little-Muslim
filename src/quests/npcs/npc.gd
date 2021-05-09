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


func _init(q_name, s) -> void:
	quest_name = q_name
	in_progress_state = s

	load_json()

	if quest_name in PlayerData.quests_completed:
		queue_free() # 
		
	if quest_name in PlayerData.quests_in_progress:
		state = in_progress_state


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


func execute() -> void:
	if (state == "null"):
		# this is when there are no further transitions
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
	if !(quest_name in PlayerData.quests_in_progress):
		(PlayerData.quests_in_progress).append(quest_name)


func process_choice(choice) -> void:
	state = curr_choices[choice]
	execute()


func _add_to_finished() -> void:
	(PlayerData.quests_in_progress).erase(quest_name)
	(PlayerData.quests_completed).append(quest_name)


func init() -> void:
	pass
