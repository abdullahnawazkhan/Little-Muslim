extends Control


func _ready() -> void:
	$HTTPRequest.request("https://example.com/")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		InternetConnection.started = true
		get_tree().change_scene("res://src/screens/log_checker/login_checker.tscn")
	else:
		$ColorRect/error_msg.visible = true


func _on_Button_button_up() -> void:
	$HTTPRequest.request("https://example.com/")
