extends actor

onready var curr = get_tree().get_current_scene().get_name()
onready var ui = get_tree().get_root().get_node(curr + "/user_interface/user_interface")

onready var character = get_node("AnimatedSprite")
onready var attack_area = get_node("PlayerAttackArea/CollisionShape2D")

onready var right_body_collision = get_node("right_body_collision")
onready var right_feet_collision = get_node("right_feet_collision")

onready var left_body_collision = get_node("left_body_collision")
onready var left_feet_collision = get_node("left_feet_collision")

onready var left_raycasts = get_node("WallRayCast/left")
onready var right_raycasts = get_node("WallRayCast/right")


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
var getting_hurt := false


func _physics_process(delta: float) -> void:
	if (character.animation != "dying"):
		if (getting_hurt == true && character.frame == 10):
			state = prev_state
			character.animation = state
			getting_hurt = false
			ui.set_is_getting_hurt(false)
			
		elif (getting_hurt != true):
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
	if (state != "dying" && getting_hurt != true):
		if (falling == true):
			prev_state = "walk"
		else:
			set_animation("walk")
		if (arrow == "right"):
			if character_direction == "left":
				character.flip_h = false
				attack_area.position.x *= -1
				
				left_body_collision.call_deferred("set_disabled", true)
				left_feet_collision.call_deferred("set_disabled", true)
				
				right_body_collision.call_deferred("set_disabled", false)
				right_feet_collision.call_deferred("set_disabled", false)
				
				if (check_wall(left_raycasts) == true):
					self.position.x += 20	
				
			move_direction = 1.0
			character_direction = "right"
		elif (arrow == "left"):
			if (falling == true):
				prev_state = "walk"
			else:
				set_animation("walk")
			if character_direction == "right":
				character.flip_h = true			
				attack_area.position.x *= -1
					
				left_body_collision.call_deferred("set_disabled", false)
				left_feet_collision.call_deferred("set_disabled", false)
				
				right_body_collision.call_deferred("set_disabled", true)
				right_feet_collision.call_deferred("set_disabled", true)
				
				if (check_wall(right_raycasts) == true):
					self.position.x -= 20	

			move_direction = -1.0
			character_direction = "left"
		else:
			move_direction = 0.0


func set_jump(val : bool):
	if (jump_pressed == false && state != "dying" && getting_hurt != true):
		
		jump_pressed = val
		jump_released = false
		ui.set_is_jumping(true)


func set_jump_release(val : bool):
	jump_released = val
	jump_pressed = false


func set_attack(val : bool):
	if (attacking == false && state != "dying" && getting_hurt != true):
		attacking = true
		ui.set_is_attacking(true)

func set_animation(anim : String):
	if (state != "dying" && getting_hurt != true):
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
	

func get_hurt(enemy : KinematicBody2D) -> void:
	if (PlayerData.health <= 0):
		pass
	else:
		PlayerData.health -= 25
		if (PlayerData.health <= 0):
			die()
		else:
			ui.set_is_getting_hurt(true)
			prev_state = character.animation
			state = "hurt"
			character.animation = "hurt"
			character_direction = "idle"
			move_direction = 0.0
			getting_hurt = true
		
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
