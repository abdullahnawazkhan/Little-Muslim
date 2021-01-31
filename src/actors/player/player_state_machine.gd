extends "res://src/actors/state_machine.gd"


onready var animator := get_tree().get_current_scene().get_node("player/AnimatedSprite")


var attack_pressed := false
var jump_pressed := false
var left_pressed := false
var right_pressed := false


func _ready():
	add_state("idle")
	add_state("walk")
	add_state("jump")
	add_state("fall")
	add_state("attack")
	add_state("block")
	add_state("dying")
	add_state("getting_hurt")
	
	call_deferred("set_state", states.idle)


func _state_logic(delta):
	parent._movement(delta, false if jump_pressed == true else true, jump_pressed)


func _get_transition(delta):
	match state:
		states.idle:
			# checking for attack_transition
			if (attack_pressed == true):
				return states.attack
			# checking for jump_transition
			if (jump_pressed == true):
				return states.jump
			# checking for walk_transition
			elif (right_pressed == true || left_pressed == true):
				return states.walk
				
		states.jump:
			# checking if player has landing on ground
			if (parent.is_on_floor() == true):
				# checking if player started press & holding the move keys during jump
				if (right_pressed == true || left_pressed == true):
					return states.walk
				else:
					return states.idle
			else:
				# if player has pressed move key during jump:
				#	state will not change but character will move in the direction
				if (right_pressed == true):
					parent.set_direction("right")
				elif (left_pressed == true):
					parent.set_direction("left")
		
		states.walk:
			# checking for attack_transition
			if (attack_pressed == true):
				return states.attack
			# checking for idle_transition
			if (right_pressed == false && left_pressed == false):
				return states.idle
			# checking for jump_transition
			if (jump_pressed == true):
				return states.jump
				
		states.attack:
			# attack area of character will be enabled on a certain frame
			if (animator.frame == 4):
				parent.enable_attack_area(true)
			
			# checking if attack animation is finised
			if (animator.frame == 9):
				if (right_pressed == true || left_pressed == true):
					return states.walk
				else:
					return states.idle

	return null


func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			animator.animation = "idle"
			parent.set_label("idle")
			parent.set_direction("null")
		states.jump:
			animator.animation = "jump"
			parent.set_label("jumping")
		states.walk:
			animator.animation = "walk"
			parent.set_label("walking")
			if (right_pressed == true):
				parent.set_direction("right")
			else:
				parent.set_direction("left")
		states.attack:
			parent.set_direction("null")
			animator.animation = "attack"
			parent.set_label("attack")


func _exit_state(old_state, new_state):
	match old_state:
		states.jump:
			jump_pressed = false
		states.attack:
			attack_pressed = false
			parent.enable_attack_area(false)


func set_direction(arrow : String):
	if (arrow == "right"):
		right_pressed = true
	elif (arrow == "left"):
		left_pressed = true
	elif (arrow == "null"):
		parent.set_direction("null")
		left_pressed = false
		right_pressed = false


func set_jump():
	jump_pressed = true


func set_jump_release():
	jump_pressed = false

func set_attack(val : bool):
	if (attack_pressed == false && jump_pressed == false):
		attack_pressed = val
