extends Control

var qibla_location_finder

var direction


func _ready() -> void:
	if Engine.has_singleton("QiblaLocationFinder"):
		qibla_location_finder = Engine.get_singleton("QiblaLocationFinder")
		print("Qibla Connection DONE")


func _process(delta: float) -> void:
	var new_direction = qibla_location_finder.getDirection()
	if (new_direction != null):
		if ($ColorRect.visible == true && new_direction != 0.0):
			$ColorRect.visible = false

		if (new_direction != direction):
			direction = new_direction
			$qibla/Sprite.rotation_degrees = direction - 90


func _on_TouchScreenButton_pressed() -> void:
	queue_free()
