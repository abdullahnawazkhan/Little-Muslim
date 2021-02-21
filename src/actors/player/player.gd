# TODO: Make the getting hurt animation better
extends "res://src/actors/actor.gd"

onready var curr = get_tree().get_current_scene().get_name()
onready var ui = get_tree().get_root().get_node(curr + "/user_interface/user_interface")

onready var character = get_node("AnimatedSprite")

onready var attack_area = get_node("PlayerAttackArea/CollisionShape2D")

onready var right_body_collision = get_node("right_body_collision")
onready var left_body_collision = get_node("left_body_collision")

onready var left_raycasts = get_node("WallRayCast/left")
onready var right_raycasts = get_node("WallRayCast/right")

onready var state_label = get_node("Label")


var move_direction := 0.0
var character_direction := "right"
var hurting := false
var died := false


func set_label(s: String) -> void:
	state_label.text = "State = " + s


func _movement(delta : float, jump_pressed : bool) -> void:
	var is_jump_interrupted
	# this will check if player is mid air and jump button is released
	# this will stop the player jump and make them fall
	if (jump_pressed == false and _velocity.y < 0.0):
		is_jump_interrupted = true
	else:
		is_jump_interrupted = false

	var direction := get_direction(jump_pressed)

	_velocity = calculate_move_velocity(_velocity, speed, direction, is_jump_interrupted, delta)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


func get_direction(jump_pressed) -> Vector2:
	return Vector2(
		move_direction,
		-1.0 if is_on_floor() and jump_pressed == true else 0.0
	)


func calculate_move_velocity(linear_velocity: Vector2, speed: Vector2, direction: Vector2, is_jump_interrupted: bool, delta: float) -> Vector2:
	var out := linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * delta

	if direction.y == -1.0:
		# the character is jumping
		out.y = speed.y * direction.y

	if is_jump_interrupted == true:
		out.y = 0.0
	
	return out


func enable_attack_area(val : bool):
	if (val == true):
		attack_area.disabled = false
	else:
		attack_area.disabled = true


func set_direction(arrow : String):
	if (arrow == "right"):
		if (character_direction == "left"):
			# flipping character
			character.flip_h = false
			attack_area.position.x *= -1
			left_body_collision.call_deferred("set_disabled", true)
			right_body_collision.call_deferred("set_disabled", false)
			
			if (check_wall(left_raycasts) == true):
				self.position.x += 20
				
		move_direction = 1.0
		character_direction = "right"
		
	elif (arrow == "left"):
		if (character_direction == "right"):
			# flipping character
			character.flip_h = true
			attack_area.position.x *= -1
			left_body_collision.call_deferred("set_disabled", false)
			right_body_collision.call_deferred("set_disabled", true)
			
			if (check_wall(left_raycasts) == true):
				self.position.x -= 20	
			
		character_direction = "left"
		move_direction = -1.0
		
	elif (arrow == "null"):
		move_direction = 0.0


func die() -> void:
	queue_free()
	PlayerData.deaths += 1
	

func get_hurt(power : float) -> void:
	if (hurting == false):
		PlayerData.health -= power
		if (PlayerData.health <= 0):
			died = true
		else:
			hurting = true
			move_direction = 0.0
			push()

func push() -> void:
	if (character_direction == "left"):
		self.position.x += 60
	else:
		self.position.x -= 60


func set_hurt(val : bool) -> void:
	hurting = val
	
	
func is_player_hurt() -> bool:
	return hurting
	

func has_player_died() -> bool:
	return died


func _on_PlayerAttackArea_body_entered(body: Node) -> void:
	var regex = RegEx.new()
	regex.compile("minotaur_a")
	
	if (regex.search(body.get_name())):
		body.get_hurt(25.0)


func check_wall(wall_raycasts) -> bool:
	for raycast in wall_raycasts.get_children():
		if (raycast.is_colliding() == true):
			return true
	return false
