extends Control

var permission_checker

var asked_user_for_permissions = false

func _ready() -> void:
	$HTTPRequest.request("https://example.com/")
	
	if Engine.has_singleton("PermissionChecker"):
		permission_checker = Engine.get_singleton("PermissionChecker")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		InternetConnection.started = true
#		get_tree().change_scene("res://src/screens/log_checker/login_checker.tscn")
		check_for_permissions()
	else:
		$ColorRect/error_msg.visible = true


func _on_Button_button_up() -> void:
	$HTTPRequest.request("https://example.com/")


func check_for_permissions():
	permission_checker.ask_for_permissions()
	asked_user_for_permissions = true


func _process(delta: float) -> void:
	if (asked_user_for_permissions == true):
		if permission_checker.permission_accepted_status() == true:
			get_tree().change_scene("res://src/screens/log_checker/login_checker.tscn")
