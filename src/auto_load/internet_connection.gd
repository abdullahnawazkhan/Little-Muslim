extends Control

signal no_internet

var request_sent
var showing_error
var in_game

var started

var error_msg = preload("res://src/ui/no_internet.tscn")

func _ready() -> void:
	request_sent = false
	showing_error = false
	in_game = false
	started = false
	
	
func _process(delta: float) -> void:
	if (request_sent == false && showing_error == false && started == true):
#		print("Sending request from process fucntion")
		$HTTPRequest.request("https://example.com/")
		request_sent = true
	


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		pass
	else:
		if (in_game == true):
			emit_signal("no_internet")
		else:
			# show error msg
			var error_instance = error_msg.instance()
			get_tree().paused = true
			get_tree().get_current_scene().add_child(error_instance)
			showing_error = true
			print("No Internet Connection")
	request_sent = false
