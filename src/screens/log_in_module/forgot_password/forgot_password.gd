extends Control

onready var lineEdit := get_node("LineEdit")
onready var httpRequest := get_node("HTTPRequest")

onready var success_msg := get_node("success_msg_area")
onready var error_msg := get_node("error_msg_area")

onready var loading_msg := get_node("loading")


func _on_TouchScreenButton_pressed() -> void:
	print("Back button pressed")
	get_tree().change_scene("res://src/screens/log_in_module/log_in/log_in.tscn")


func _on_Button_button_up() -> void:
	loading_msg.visible = true
	var text = lineEdit.text
	Firebase.forgot_my_password(text, httpRequest)


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		print("Email Sent")
		loading_msg.visible = false
		success_msg.visible = true
		# pop msg email reset password successful
	else:
		# display pop up no such email exists
		loading_msg.visible = false
		error_msg.visible = true
		print("error sending email")
		


func _on_error_exit_button_pressed() -> void:
	error_msg.visible = false


func _on_success_exit_button_pressed() -> void:
	success_msg.visible = false
