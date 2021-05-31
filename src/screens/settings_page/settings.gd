extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_back_as_close() -> void:
	$back.visible = false
	$close.visible = true
	


func _on_close_pressed() -> void:
	self.queue_free()
