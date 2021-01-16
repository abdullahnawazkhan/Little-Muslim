extends Actor

onready var curr = get_tree().get_current_scene().get_name()
onready var ui = get_tree().get_root().get_node(curr + "/UserInterface/UserInterface")

onready var character = get_node("AnimatedSprite")
onready var attack_area = get_node("PlayerAttackArea/CollisionShape2D")

onready var right_body_collision = get_node("right_body_collision")
onready var right_feet_collision = get_node("right_feet_collision")
onready var right_head_collision = get_node("right_head_collision")

onready var left_body_collision = get_node("left_body_collision")
onready var left_feet_collision = get_node("left_feet_collision")
onready var left_head_collision = get_node("left_head_collision")

onready var left_raycasts = get_node("WallRayCast/left_ray")
onready var right_raycasts = get_node("WallRayCast/right_ray")


var move_direction := 0.0
var character_direction := "right"

var jump_pressed := false
var jump_released := false

var prev_height := 0.0
var falling := false

var state := "idle"
var prev_state := "idle"

var attacking := false
var blocking := false


func _physics_process(delta: float) -> void:
	if (character.animation != "dying"):
		if (attacking == true && character.frame == 4):
			attack_area.disabled = false
		
		if (attacking == true && character.frame == 9):
			# attack has finished
			attacking = false
			attack_area.disabled = true
			state = prev_state
			character.animation = state
			character.speed_scale = 2
			ui.set_is_attacking(false)

		var is_jump_interrupted := jump_released == true and _velocity.y < 0.0

		var direction := get_direction()

		_velocity = calculate_move_velocity(_velocity, speed, direction, is_jump_interrupted)
		_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


func get_direction() -> Vector2:
	return Vector2(
		move_direction,
		-1.0 if is_on_floor() and jump_pressed == true else 0.0
	)


func calculate_move_velocity(linear_velocity: Vector2, speed: Vector2, direction: Vector2, is_jump_interrupted: bool ) -> Vector2:
	var out := linear_velocity
	out.x = speed.x * direction.x
	prev_height = out.y
	out.y += gravity * get_physics_process_delta_time()
	

	if direction.y == -1.0:
		out.y = speed.y * direction.y
	else:
		jump_pressed = false
		if is_on_floor() == false:
			if (prev_height < out.y && state == "jump"):
				falling = true

	if is_jump_interrupted == true:
		out.y = 0.0

	if (is_on_floor() == true && falling == true):
		state = prev_state
		character.animation = state
		falling = false
		jump_pressed = false
		jump_released = true
		ui.set_is_jumping(false)
		
	return out


func set_direction(arrow : String):
	if (state != "dying"):
		if (arrow == "right"):
			if character_direction == "left":
				left_body_collision.call_deferred("set_disabled", true)
				left_feet_collision.call_deferred("set_disabled", true)
				left_head_collision.call_deferred("set_disabled", true)
				
				right_body_collision.call_deferred("set_disabled", false)
				right_feet_collision.call_deferred("set_disabled", false)
				right_head_collision.call_deferred("set_disabled", false)
				
				if (check_wall(left_raycasts) == true):
					self.position.x += 20	
				
#				head_collision.position.x *= -1
#				body_collision.position.x *= -1
#				attack_area.position.x *= -1
#				feet_collision.position.x *= -1
			move_direction = 1.0
			character.flip_h = false
			character_direction = "right"
		elif (arrow == "left"):
			if character_direction == "right":				
				left_body_collision.call_deferred("set_disabled", false)
				left_feet_collision.call_deferred("set_disabled", false)
				left_head_collision.call_deferred("set_disabled", false)
				
				right_body_collision.call_deferred("set_disabled", true)
				right_feet_collision.call_deferred("set_disabled", true)
				right_head_collision.call_deferred("set_disabled", true)
				
				if (check_wall(right_raycasts) == true):
					self.position.x -= 20	
#				head_collision.position.x *= -1
#				body_collision.position.x *= -1
#				attack_area.position.x *= -1
#				feet_collision.position.x *= -1
			move_direction = -1.0
			character.flip_h = true
			character_direction = "left"
		else:
			move_direction = 0.0


func set_jump(val : bool):
	if (jump_pressed == false && state != "dying"):
		jump_pressed = val
		jump_released = false
		ui.set_is_jumping(true)


func set_jump_release(val : bool):
	jump_released = val
	jump_pressed = false


func set_attack(val : bool):
	if (attacking == false && state != "dying"):
		attacking = true
		ui.set_is_attacking(true)

func set_animation(anim : String):
	if (state != "dying"):
		if (anim == "walk"):
			if (state == "idle"):
				prev_state = state
				state = anim
				character.animation = anim
			elif (state == "jump"):
				if is_on_floor() == true:
					prev_state = state
					state = anim
					character.animation = anim
		elif (anim == "jump"):
			prev_state = state
			state = anim
			character.animation = anim
		elif (anim == "idle"):
			if (state == "jump"):			
				prev_state = anim
			else:
				prev_state = state
				state = anim
				character.animation = anim
		elif (anim == "attack"):
			prev_state = state
			state = anim
			character.animation = anim
			character.speed_scale = 3


func die() -> void:
	PlayerData.deaths += 1
	character.animation = "dying"
	state = "dying"
	ui.stop()
	

func get_hurt() -> void:
	print("Getting hit")


func _on_PlayerAttackArea_body_entered(body: Node) -> void:
	if (body.get_name() == "Minotaur_1"):
		body.get_hurt()


func check_wall(wall_raycasts) -> bool:
	for raycast in wall_raycasts.get_children():
		if (raycast.is_colliding() == true):
			return true
	return false
