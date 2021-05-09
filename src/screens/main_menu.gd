extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_log_out_button_up() -> void:
	var dir = Directory.new()
	dir.remove("user://save_login.dat")
	get_tree().change_scene("res://src/screens/start_up_screen.tscn")
