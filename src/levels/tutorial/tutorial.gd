extends Node2D

onready var jump_hint := get_node("user_interface/jump_hint")
onready var walk_hint := get_node("user_interface/walk_hint")
onready var attack_hint := get_node("user_interface/attack_hint")
onready var memorization_hint := get_node("user_interface/memorization_hint")

var learning_state = preload("res://src/memorization/learning/Control.tscn")

func _on_Area2D_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		jump_hint.visible = true


func _on_TouchScreenButton_pressed() -> void:
	jump_hint.visible = false
	$jump_hint.queue_free()


func _on_walk_hint_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		walk_hint.visible = true


func _on_walk_exit_pressed() -> void:
	walk_hint.visible = false
	$walk_hint.queue_free()


func _on_attack_hint_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		attack_hint.visible = true


func _on_attack_exit_pressed() -> void:
	attack_hint.visible = false
	$attack_hint.visible = false


func _on_memorizing_hint_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		memorization_hint.visible = true


func _on_memo_exit_pressed() -> void:
	memorization_hint.visible = false
	$memorizing_hint.queue_free()


func _on_coin_body_entered(body: Node) -> void:
	var UI = get_tree().get_current_scene().get_node("user_interface").get_node("user_interface")
	$user_interface/loading.visible = true
	yield(get_tree().create_timer(0.1), "timeout")
	
	var obj = learning_state.instance()
	obj.init("Surah Al-Ikhlas", 112, "all")
	obj.connect("recitation_done", self, "memo_done")
	UI.add_child(obj)
	
	$user_interface/loading.visible = false
	get_tree().paused = true


func _on_portal_Area2D_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		get_tree().change_scene("res://src/levels/forest/forest_a.tscn")


func memo_done(val):
	get_tree().paused = false
	$coin.visible = false
