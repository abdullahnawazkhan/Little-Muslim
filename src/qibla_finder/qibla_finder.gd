extends Control

var qibla_location_finder

var direction

var is_location_on


func _ready() -> void:
	if Engine.has_singleton("QiblaLocationFinder"):
		qibla_location_finder = Engine.get_singleton("QiblaLocationFinder")
		
		if qibla_location_finder.get_location_on() == true:
			is_location_on = true
		else:
			$error_msg.visible = true
			is_location_on = false
		
		


func _process(delta: float) -> void:
	if qibla_location_finder.get_location_on() == true:
		is_location_on = true
	else:
		$error_msg.visible = true
		is_location_on = false

	if is_location_on == true:
		var new_direction = qibla_location_finder.getDirection()
		if (new_direction != null):
			if ($ColorRect.visible == true && new_direction != 0.0):
				$ColorRect.visible = false

			if (new_direction != direction):
				direction = new_direction
				$qibla/Sprite.rotation_degrees = direction - 90


func _on_TouchScreenButton_pressed() -> void:
	queue_free()


func _on_Button_button_up() -> void:
	if qibla_location_finder.get_location_on() == true:
		is_location_on = true
		$error_msg.visible = false
	else:
		is_location_on = false
