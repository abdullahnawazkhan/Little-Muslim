# TODO : Implement Falling state

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
	add_state("falling")
	add_state("attack")
	add_state("block")
	add_state("dying")
	add_state("hurt")
	
	call_deferred("set_state", states.idle)


func _state_logic(delta):
	# player.gd will handle the actual movement
	# logically want the player needs is the move direction and whether jump is pressed or not
	# move direction is set when player presses the arrow buttons so we only send if jump is pressed via param
	parent._movement(delta, jump_pressed)


func _get_transition():
	match state:
		states.idle:
			# checking if player has died
			if (parent.has_player_died() == true):
				return states.dying
			# checking if player getting hurt
			if (parent.is_player_hurt() == true):
				return states.hurt
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
				# if user presses attack button during jump it will neglect it
				attack_pressed = false
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
				animator.speed_scale = 3.0
			
			# checking if attack animation is finised
			if (animator.frame == 9):
				if (right_pressed == true || left_pressed == true):
					return states.walk
				else:
					return states.idle
					
		states.hurt:
			# TODO : player is hurt and is pushed of floor and falls [for falling state]
			
			# checking if hurt animation has finished
			if (animator.frame == 17):
				return previous_state
		
		states.dying:
			# checking if dying animation has finished
			if (animator.frame == 17):
				parent.die()

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
			if (parent.character_direction == "right"):
				animator.offset = Vector2(76, 42)
			elif (parent.character_direction == "left"):
				animator.offset = Vector2(-76, 42)
			
		states.hurt:
			parent.set_direction("null")
			animator.animation = "hurt"
			animator.speed_scale = 4.0
			parent.set_label("getting hurt")
			
		states.dying:
			parent.set_direction("null")
			animator.animation = "dying"
			if (parent.character_direction == "right"):
				animator.offset = Vector2(-233, 25)
			elif (parent.character_direction == "left"):
				animator.offset = Vector2(233, 25)
			parent.set_label("dying")


func _exit_state(old_state, new_state):
	match old_state:
		states.jump:
			jump_pressed = false
			
		states.attack:
			attack_pressed = false
			parent.enable_attack_area(false)
			animator.speed_scale = 2.0
			animator.offset = Vector2(0, 0)
			
		states.hurt:
			parent.set_hurt(false)
			animator.speed_scale = 2.0
			animator.offset = Vector2(0, 0)


func set_direction(arrow : String):
	if (state != states.hurt):
		if (arrow == "right"):
			right_pressed = true
		elif (arrow == "left"):
			left_pressed = true
		elif (arrow == "null"):
			parent.set_direction("null")
			left_pressed = false
			right_pressed = false


func set_jump():
	if (attack_pressed == false && jump_pressed == false && state != states.hurt):
		jump_pressed = true


func set_jump_release():
	jump_pressed = false


func set_attack(val : bool):
	if (attack_pressed == false && jump_pressed == false && state != states.hurt):
		attack_pressed = val
