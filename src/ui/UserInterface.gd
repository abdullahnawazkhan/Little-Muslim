extends Control

onready var scene_tree : = get_tree()
onready var paused_overly : ColorRect = get_node("PauseOverlay")
onready var score : Label = get_node("Label")
onready var pause_title : Label = get_node("PauseOverlay/Title")
onready var curr = get_tree().get_current_scene().get_name()
onready var player : Actor =  get_tree().get_root().get_node(curr + "/Player")
onready var left_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_left")
onready var right_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_right")
onready var attack_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_attack")
onready var jump_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_jump")


var is_jumping := false
var is_attacking := false

var paused := false setget set_paused

func _ready() -> void:
	PlayerData.connect("score_updated", self, "update_interface")
	PlayerData.connect("player_died", self, "_on_PlayerData_player_died")
	update_interface()
	

func _on_PlayerData_player_died() -> void:
	yield(get_tree().create_timer(1.5), "timeout")
	player.queue_free()
	print("Player Died")
	self.paused = true
	pause_title.text = "You died"
	
	

func _unhandled_input(event: InputEvent) -> void:
	if pause_title.text != "You died":
		if event.is_action_pressed("paused"):
			self.paused = not paused
			scene_tree.set_input_as_handled()


func update_interface() -> void:
	score.text = "Score: %s" % PlayerData.score


func set_paused(value : bool) -> void:
	paused = value
	scene_tree.paused = value
	paused_overly.visible = value


func set_is_jumping(value : bool) -> void:
	is_jumping = value

func set_is_attacking(value : bool) -> void:
	is_attacking = value


func stop() -> void:
	left_button.visible = false
	right_button.visible = false
	jump_button.visible = false
	attack_button.visible = false


func _on_TouchScreenButton_Jump_pressed() -> void:
	if (is_jumping == false):
		player.set_jump(true)
		player.set_animation("jump")


func _on_TouchScreenButton_Jump_released() -> void:
	player.set_jump_release(true)


func _on_TouchScreenButton_right_pressed() -> void:
	player.set_direction("right")
	player.set_animation("walk")


func _on_TouchScreenButton_right_released() -> void:
#	print("Button released")
	player.set_direction("null")
	player.set_animation("idle")


func _on_TouchScreenButton_left_pressed() -> void:
	player.set_direction("left")
	player.set_animation("walk")


func _on_TouchScreenButton_left_released() -> void:
#	print("Button released")
	player.set_direction("null")
	player.set_animation("idle")
	


func _on_TouchScreenButton_attack_pressed() -> void:
	if (is_attacking == false):
		player.set_animation("attack")
		player.set_attack(true)



func _on_TouchScreenButton_pause_pressed() -> void:
	pass # Replace with function body.
