extends Actor

onready var curr = get_tree().get_current_scene().get_name()
onready var jump_button = get_tree().get_root().get_node(curr + "/UserInterface/UserInterface")
onready var character = get_tree().get_current_scene().get_node("Player/AnimatedSprite")

var move_direction := 0.0

var jump_pressed := false
var jump_released := false

var prev_height := 0.0
var falling := false

var state := "idle"
var prev_state := "idle"


func _physics_process(delta: float) -> void:
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
		
	return out


func set_direction(arrow : String):
	if (arrow == "right"):
		move_direction = 1.0
		character.flip_h = false
	elif (arrow == "left"):
		move_direction = -1.0
		character.flip_h = true
	else:
		move_direction = 0.0

func set_jump(state : bool):
	if (jump_pressed == false):
		jump_pressed = state
		jump_released = false

func set_jump_release(state : bool):
	jump_released = state
	jump_pressed = false

func die() -> void:
	PlayerData.deaths += 1
	queue_free()
	
func set_animation(anim : String):
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
