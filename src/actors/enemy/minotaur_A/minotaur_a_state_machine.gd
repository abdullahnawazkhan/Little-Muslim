# TODO: need to handle when player attacked while enenmy is in hurt state

extends "res://src/actors/state_machine.gd"

onready var animator = parent.get_node("AnimatedSprite")

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("attack")
	add_state("dying")
	add_state("hurt")
	
	call_deferred("set_state", states.walk)


func _state_logic(delta):
	parent._movement(delta, true if state == 1 else false)


func _get_transition():
	match state:
		states.idle:
			# checking if player is attacking
			if (parent.is_getting_hurt() == true):
				return states.hurt
			# checking if player has died
			if (parent.has_died() == true):
				return states.dying
			# checking is attack timeout has finished
			if (parent.is_stopped_pause_timer() == true):
				return states.attack
			# checking if player has left visibility region
			if (parent.has_player_entered() == false):
				return states.walk

		states.walk:
			# checking if player is attacking
			if (parent.is_getting_hurt() == true):
				return states.hurt
			# checking if player has died
			if (parent.has_died() == true):
				return states.dying
			# checking if player entered visibility region
			if (parent.has_player_entered() == true):
				return states.attack

		states.attack:
			# checking if player has died
			if (parent.has_died() == true):
				return states.dying
			# checking if player is attacking
			if (parent.is_getting_hurt() == true):
				return states.hurt
			# checking for a certain animation frame to activate attack box
			if (animator.frame == 7):
				parent.set_attack_area(true)
			# checking if attack timeout has started
			if (parent.is_stopped_attack_timer() == true):
				return states.idle
			# checking if player has left visibility region
			elif (parent.has_player_entered() == false):
				return states.walk
				
		states.hurt:
			# checking if player has died
			if (parent.has_died() == true):
				return states.dying
			# checking if hurt animation has stopped
			if (animator.frame == 13):
				parent.set_hurt(false)
				return previous_state
		
		states.dying:
			# checking if dying animation has finished
			if (animator.frame == 10):
				animator.stop()
				parent.die()
			
	return null


func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			animator.animation = "idle"
			parent.start_pause_timer()
			parent.set_label("idle")
			parent.set_attack_area(false)

		states.attack:
			animator.animation = "attack"
			parent.start_attack_timer()
			parent.set_label("attacking")

		states.walk:
			animator.animation = "walk"
			parent.set_label("walking")
			parent.stop_attack_timer()
			parent.stop_pause_timer()
			parent.set_attack_area(false)

		states.dying:
			animator.animation = "die"
			parent.set_label("dying")

		states.hurt:
			animator.animation = "hurt"
			parent.set_label("getting_hurt")
			parent.push()


func _exit_state(old_state, new_state):
	pass
