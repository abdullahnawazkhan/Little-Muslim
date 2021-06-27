extends Control


func _ready() -> void:
	print("No Internet")
	InternetConnection.showing_error = true


func _on_Button_button_up() -> void:
	$HTTPRequest.request("https://example.com/")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		InternetConnection.started = true
		InternetConnection.showing_error = false
		get_tree().paused  = false
		queue_free()
