# TODO:
#	- enable attack area at proper attack animation frame
#	- fix physics layers

extends "res://src/Actors/Actor.gd"

onready var character := get_node("AnimatedSprite")
onready var player := get_tree().get_current_scene().get_node("Player")
onready var player_detector := get_node("PlayerDetector/CollisionShape2D")
onready var attack_area := get_node("Minotaur1AttackArea/CollisionShape2D")
onready var character_collision := get_node("CollisionShape2D")
onready var attack_timer := get_node("AttackTimer")
onready var pause_timer := get_node("PauseTimer")

var score := 100
var health := 100

var direction := "left"
var moving := true

var getting_hurt := false
var is_attacking := false
var dying := false

func die() -> void:
	moving = false
	character.animation = "die"
	dying = true

func get_hurt() -> void:
	if (health <= 0):
		pass
	else:
		if (direction == "left"):
			if (player.character_direction == "left"):
				if is_on_wall() == false:
					self.position.x += -60.0
				flip()
			else:
				if is_on_wall() == false:
					self.position.x += 60.0
		elif (direction == "right"):
			if (player.character_direction == "right"):
				if is_on_wall() == false:
					self.position.x += 60.0
				flip()
			else:
				if is_on_wall() == false:
					self.position.x += -60.0
		
		health -= 25
		if (health <= 0):
			die()
		else:
			character.animation = "hurt"
			moving = false
			getting_hurt = true
			
		attack_timer.stop()
		pause_timer.set_wait_time(1)
		pause_timer.start()


func _ready() -> void:
	speed.x = 100
	set_physics_process(false)
	_velocity.x = -speed.x # so that moves towards the player at the start


func _physics_process(delta: float) -> void:
	if character.animation == "die" && character.frame == 10:
		queue_free()
		
	if character.animation == "hurt" && character.frame == 11:
		character.animation = "attack"
		getting_hurt = false

	if (moving == true):
		if is_on_wall():
			flip()
				
		_velocity.y = move_and_slide(_velocity, FLOOR_NORMAL).y



func _on_PlayerDetector_body_entered(body: Node) -> void:
	if (body.get_name() == "Player"):
		set_attack(true)
		moving = false
		is_attacking = true


func _on_PlayerDetector_body_exited(body: Node) -> void:
	if (body.get_name() == "Player"):
		set_attack(false)
		is_attacking = false
		moving = true
		character.animation = "walk"


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


func set_attack(value : bool) -> void:
	if (dying == true):
		return
	if (value == true):
		attack_timer.set_wait_time(1.2)
		attack_timer.start()
		character.animation = "attack"
		attack_area.call_deferred("set_disabled", false)
	elif (value == false):
		attack_area.call_deferred("set_disabled", true)		


func _on_Minotaur1AttackArea_body_entered(body: Node) -> void:
	if (body.get_name() == "Player"):
		body.get_hurt()


func _on_AttackTimer_timeout() -> void:
	attack_timer.stop()
	set_attack(false)
	pause_timer.set_wait_time(2)
	pause_timer.start()


func _on_PauseTimer_timeout() -> void:
	if (is_attacking == true):
		pause_timer.stop()
		set_attack(true)
