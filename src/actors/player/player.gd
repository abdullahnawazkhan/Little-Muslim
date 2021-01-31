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


func set_label(s: String) -> void:
	state_label.text = "State = " + s


func _movement(delta : float, jump_released : bool, jump_pressed : bool) -> void:
	var is_jump_interrupted := jump_released == true and _velocity.y < 0.0

	var direction := get_direction(jump_pressed)

	_velocity = calculate_move_velocity(_velocity, speed, direction, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


func get_direction(jump_pressed) -> Vector2:
	return Vector2(
		move_direction,
		-1.0 if is_on_floor() and jump_pressed == true else 0.0
	)


func calculate_move_velocity(linear_velocity: Vector2, speed: Vector2, direction: Vector2, is_jump_interrupted: bool) -> Vector2:
	var out := linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()

	if direction.y == -1.0:
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
	PlayerData.deaths += 1
	character.animation = "dying"
	ui.stop()
	

func get_hurt(enemy : KinematicBody2D) -> void:
	if (PlayerData.health <= 0):
		pass
	else:
		PlayerData.health -= 25
		if (PlayerData.health <= 0):
			die()
		else:
			ui.set_is_getting_hurt(true)
			character.animation = "hurt"
			character_direction = "idle"
			move_direction = 0.0
		
		if (character_direction == "left"):
			if (enemy.direction == "left"):
				if is_on_wall() == false:
					self.position.x += -30.0
				set_direction("right")
			else:
				if is_on_wall() == false:
					self.position.x += 30.0
		elif (character_direction == "right"):
			if (enemy.direction == "right"):
				if is_on_wall() == false:
					self.position.x += 30.0
				set_direction("left")
			else:
				if is_on_wall() == false:
					self.position.x += -30.0


func _on_PlayerAttackArea_body_entered(body: Node) -> void:
	var regex = RegEx.new()
	regex.compile("Minotaur_\\d")
	
	if (regex.search(body.get_name())):
		body.get_hurt()


func check_wall(wall_raycasts) -> bool:
	for raycast in wall_raycasts.get_children():
		if (raycast.is_colliding() == true):
			return true
	return false
