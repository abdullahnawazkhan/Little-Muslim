extends Control

onready var scene_tree : = get_tree()
onready var paused_overly : ColorRect = get_node("pause_overlay")
onready var score : Label = get_node("score_label")
onready var health : Label = get_node("health_label")
onready var pause_title : Label = get_node("pause_overlay/title")
onready var curr = get_tree().get_current_scene().get_name()
onready var player : actor =  get_tree().get_root().get_node(curr + "/player")
onready var player_sm := get_tree().get_root().get_node(curr + "/player/state_machine")

onready var left_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_left")
onready var right_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_right")
onready var attack_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_attack")
onready var jump_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_jump")
onready var enter_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_enter")
onready var interact_button : TouchScreenButton = get_node("touch_buttons/TouchScreenButton_interact")
onready var touch_buttons : ColorRect = get_node("touch_buttons")

onready var dialog : ColorRect = get_node("dialog_overlay")
onready var dialog_text : RichTextLabel = get_node("dialog_overlay/dialog_box/RichTextLabel")
onready var next_button : TouchScreenButton = get_node("dialog_overlay/dialog_box/TouchScreenButton")
onready var sprite : Sprite = get_node("dialog_overlay/dialog_box/Sprite")
onready var choice_button : Button = get_node("dialog_overlay/choices/HBoxContainer/Button")
onready var choice_area : ColorRect = get_node("dialog_overlay/choices")
onready var choice_list : VBoxContainer = get_node("dialog_overlay/choices/HBoxContainer")

var b = []

var npc_child = null

var is_jumping := false
var is_attacking := false
var is_getting_hurt := false

var is_paused := false setget set_paused

enum pause_action {MAIN_MENU, QUIT}
var current_action

var scene_change_path := ""


func _ready() -> void:
	PlayerData.connect("score_updated", self, "update_interface")
	PlayerData.connect("player_health_changed", self, "update_interface")
	PlayerData.connect("player_died", self, "_on_PlayerData_player_died")
	update_interface()


func _on_PlayerData_player_died() -> void:
	get_tree().change_scene("res://src/screens/minor_screens/dead_screen.tscn")
	

func update_interface() -> void:
	score.text = "Score: " + str(PlayerData.score)
	health.text = "Health: " + str(PlayerData.health) + "%"


func set_paused(value : bool) -> void:
#	is_paused = value
	paused_overly.visible = value
	scene_tree.paused = value


func set_is_jumping(value : bool) -> void:
	is_jumping = value


func set_is_attacking(value : bool) -> void:
	is_attacking = value


func set_is_getting_hurt(value : bool) -> void:
	is_getting_hurt = value


func show_enter_button(value : bool) -> void:
	enter_button.visible = value
	

func show_interact_button(value : bool) -> void:
	interact_button.visible = value


func set_npc(target) -> void:
	npc_child = target


func _on_TouchScreenButton_right_pressed() -> void:
	player_sm.set_direction("right")


func _on_TouchScreenButton_right_released() -> void:
	player_sm.set_direction("null")


func _on_TouchScreenButton_left_pressed() -> void:
	player_sm.set_direction("left")


func _on_TouchScreenButton_left_released() -> void:
	player_sm.set_direction("null")


func _on_TouchScreenButton_attack_pressed() -> void:
	player_sm.set_attack(true)


func _on_TouchScreenButton_pause_pressed() -> void:
	self.is_paused = true
	pause_title.text = "Game Paused"


func _on_TouchScreenButton_jump_pressed() -> void:
	player_sm.set_jump()


func _on_TouchScreenButton_jump_released() -> void:
	player_sm.set_jump_release()


func _on_TouchScreenButton_interact_pressed() -> void:
	dialog.visible = true
	scene_tree.paused = true
	touch_buttons.visible = false
	npc_child.init()
	npc_child.execute()
	next_button.connect("pressed", npc_child, "execute")
	

func set_text(text) -> void:
	dialog_text.text = text
	
	
func set_texture(texture) -> void:
	sprite.texture = texture


func dialog_end() -> void:
	dialog.visible = false
	scene_tree.paused = false
	touch_buttons.visible = true
	next_button.disconnect("pressed", npc_child, "execute")
	
	choice_button.disconnect("pressed", npc_child, "process_choice")
	clear_choices()
	

func generate_choices(choices) -> void:
	clear_choices()
	
	choice_area.visible = true
	
	for c in choices:
		if (choice_button.text == ""):
			choice_button.text = c
			choice_button.connect("pressed", npc, "process_choice", [c])
		else:
			var new_button = choice_button.duplicate()
			b.append(new_button)
			choice_list.add_child(new_button)
			new_button.text = c
			new_button.connect("pressed", npc, "process_choice", [c])


func clear_choices() -> void:
	choice_button.text = ""
	
	for a in b:
		a.queue_free()
		
	b = []


func hide_choices() -> void:
	choice_area.visible = false


func set_scene_change_path(path) -> void:
	scene_change_path = path


func _on_TouchScreenButton_enter_pressed() -> void:
	var save = load(scene_change_path)
	var save_scene = save.instance()
	get_parent().add_child(save_scene)



func _on_main_menu_button_up() -> void:
	$pause_overlay/confirmation_overlay.visible = true
	current_action = pause_action.MAIN_MENU


func _on_quit_button_up() -> void:
	$pause_overlay/confirmation_overlay.visible = true
	current_action = pause_action.QUIT


func _on_yes_button_released() -> void:
	if current_action == pause_action.MAIN_MENU:
		get_tree().paused = false
		get_tree().change_scene("res://src/screens/main_menu.tscn")
	
	if current_action == pause_action.QUIT:
		get_tree().quit()


func _on_no_button_released() -> void:
	$pause_overlay/confirmation_overlay.visible = false
