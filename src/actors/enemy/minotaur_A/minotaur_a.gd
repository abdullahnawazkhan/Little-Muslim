extends "res://src/actors/actor.gd"

onready var character := get_node("AnimatedSprite")
#onready var player := get_tree().get_current_scene().get_node("player")
onready var player_detector := get_node("PlayerDetector/CollisionShape2D")
onready var attack_area := get_node("Minotaur1AttackArea/CollisionShape2D")
onready var character_collision := get_node("CollisionShape2D")
onready var attack_timer := get_node("AttackTimer")
onready var pause_timer := get_node("PauseTimer")
onready var state_label := get_node("state_label")
onready var health_label := get_node("health_label")

onready var rays := get_node("rays")

var score := 100
var health := 100.0
var direction := "left"

var player_entered := false
var getting_hurt := false
var is_dead := false

func set_label(s : String) -> void:
	state_label.text = "State = " + s

func set_health_label(s : int) -> void:
	health_label.text = "Health = " + str(s)


func start_pause_timer() -> void:
	pause_timer.set_wait_time(2)
	pause_timer.start()


func stop_pause_timer() -> void:
	pause_timer.stop()


func is_stopped_pause_timer() -> bool:
	return pause_timer.is_stopped()


func start_attack_timer() -> void:
	attack_timer.set_wait_time(1.2)
	attack_timer.start()


func stop_attack_timer() -> void:
	attack_timer.stop()

	
func is_stopped_attack_timer() -> bool:
	return attack_timer.is_stopped()


func die() -> void:
	PlayerData.score += score
	self.queue_free()

func get_hurt(power : float) -> void:
	health -= power
	set_health_label(health)
	if (health <= 0.0):
		is_dead = true
	else:
		getting_hurt = true


func is_getting_hurt() -> bool:
	return getting_hurt


func has_died() -> bool:
	return is_dead


func set_hurt(val : bool) -> void:
	getting_hurt = val


func _ready() -> void:
	speed.x = 100
	set_physics_process(false)
	_velocity.x = -speed.x # so that enemy moves towards the player at the start

func _movement(delta: float, moving) -> void:
	if (moving == true):
		if check_fall() == true || is_on_wall():
			flip()
				
		_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y

func push() -> void:
	if (direction == "left"):
		self.position.x += 30
	else:
		self.position.x -= 30


func check_fall() -> bool:
	for raycast in rays.get_children():
		if (raycast.is_colliding() == false):
			return true
	return false



func _on_PlayerDetector_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		player_entered = true


func _on_PlayerDetector_body_exited(body: Node) -> void:
	if (body.get_name() == "player"):
		player_entered = false


func flip() -> void:
	if (direction == "left"):
		character.flip_h = false
		direction = "right"
	elif (direction == "right"):
		character.flip_h = true
		direction = "left"
	
	_velocity.x *= -1.0
	attack_area.position.x *= -1
	player_detector.position.x *= -1
	character_collision.position.x *= -1


func set_attack_area(val : bool) -> void:
	if val == true:
		attack_area.call_deferred("set_disabled", false)
	else:
		attack_area.call_deferred("set_disabled", true)


func _on_Minotaur1AttackArea_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		body.get_hurt(50)


func _on_AttackTimer_timeout() -> void:
	attack_timer.stop()


func _on_PauseTimer_timeout() -> void:
	pause_timer.stop()


func has_player_entered() -> bool:
	return player_entered


func _on_Area2D_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
