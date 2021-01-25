extends Actor

onready var character = get_tree().get_current_scene().get_node("Player/AnimatedSprite")

onready var left_feet = get_node("left_feet_collision")
onready var right_feet = get_node("right_feet_collision")

onready var left_body = get_node("left_body_collision")
onready var right_body = get_node("right_body_collision")

onready var left_raycasts = get_node("WallRayCast/left")
onready var right_raycasts = get_node("WallRayCast/right")

var move_direction := 0.0
var jump_pressed := false
var jump_released := false

var character_direction := "right"

func _physics_process(delta: float) -> void:
	var is_jump_interrupted := Input.is_action_just_released("jump") and _velocity.y < 0.0

	var direction := get_direction()

	_velocity = calculate_move_velocity(_velocity, speed, direction, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		-1.0 if is_on_floor() and Input.is_action_just_pressed("jump") else 0.0
	)


func calculate_move_velocity(linear_velocity: Vector2, speed: Vector2, direction: Vector2, is_jump_interrupted: bool ) -> Vector2:
	if direction.x < 0.0:
		character.animation = "walk"
		flip("left")
		character.flip_h = true
	elif direction.x > 0.0:
		flip("right")
		character.animation = "walk"
		character.flip_h = false
	else:
		character.animation = "idle"
	
	var out := linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()

	if direction.y == -1.0:
		character.animation = "jump"
		out.y = speed.y * direction.y

	if is_jump_interrupted == true:
		out.y = 0.0

	return out

func die() -> void:
	queue_free()
	
func flip(t_direction : String) -> void:
	if (t_direction == "right"):
		if (character_direction == "left"):
			left_body.call_deferred("set_disabled", true)
			left_feet.call_deferred("set_disabled", true)
				
			right_body.call_deferred("set_disabled", false)
			right_feet.call_deferred("set_disabled", false)
			
			if (check_wall(left_raycasts) == true):
				self.position.x += 20
		character_direction = "right"
	elif (t_direction == "left"):
		if (character_direction == "right"):
			left_body.call_deferred("set_disabled", false)
			left_feet.call_deferred("set_disabled", false)
			
			right_body.call_deferred("set_disabled", true)
			right_feet.call_deferred("set_disabled", true)
				
			if (check_wall(right_raycasts) == true):
				self.position.x -= 20	
		character_direction = "left"


func check_wall(wall_raycasts) -> bool:
	for raycast in wall_raycasts.get_children():
		if (raycast.is_colliding() == true):
			return true
	return false
