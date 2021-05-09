extends Node2D

export(String, FILE) var scene_path := ""

func _get_configuration_warning() -> String:
	if not scene_path:
		return "The next scene property can't be empty"
	else:
		return ""

onready var ui := get_tree().get_current_scene().get_node("user_interface/user_interface")


func _on_transport_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		get_tree().change_scene("res://src/levels/forest/forest_b.tscn")


func _on_dead_area_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		body.die()


func _on_building_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_enter_button(true)


func _on_building_body_exited(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_enter_button(false)



func _on_masjid_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_enter_button(true)
		ui.set_scene_change_path("res://src/screens/minor_screens/saving_screen/saving.tscn")


func _on_masjid_body_exited(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_enter_button(false)
