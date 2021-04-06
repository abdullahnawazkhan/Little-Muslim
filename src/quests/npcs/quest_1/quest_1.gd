extends "../npc.gd"


func _init().("quest_1", "004"):
	pass


func _on_Area2D_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_interact_button(true)
		ui.set_npc(self)
		ui.set_texture($Sprite.texture)


func _on_Area2D_body_exited(body: Node) -> void:
	if (body.get_name() == "player"):
		ui.show_interact_button(false)


func init() -> void:
	load_json()
