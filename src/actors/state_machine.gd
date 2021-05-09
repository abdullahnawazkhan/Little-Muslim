extends Node2D
class_name state_machine

# this is the current state of the child
var state = null setget set_state
var previous_state = null

# this is a dictionary, which will hold a list of all states of the child
var states = {}

onready var parent = get_parent()


func _physics_process(delta: float):
	# each statemachine child will go through this for each iteration in the main game loop
	# which will firstly run the state logic which will mainly consist of movements
	# then will check for transitions for the current state the child is in
	# if a transition occurs, state will be changed
	if state != null:
		_state_logic(delta)
		var transition = _get_transition()
		if transition != null:
			set_state(transition)


func _state_logic(delta):
	# will mainly handle the movement
	pass


func _get_transition():
	# this is a virtual method that a child must implement
	# this will check for transitions for each state
	# needs to be implemented for every single state of the child
	return null


func _enter_state(new_state, old_state):
	# this is a virtual method that a child must implement
	# this will hold the code which should run when entering a state
	pass


func _exit_state(old_state, new_state):
	# this is a virtual method that a child must implement
	# this will hold the code which should run when exiting a state
	pass


func set_state(new_state):
	# this method is called inside physics process
	# if a transition occurs, this will handle the changing of states
	# changing of state is a two step process, exiting the current one and entering the new one
	previous_state = state
	state = new_state
	
	if (previous_state != null):
		_exit_state(previous_state, new_state)
	
	if (new_state != null):
		_enter_state(new_state, previous_state)


func add_state(state_name : String):
	# this will add states in the main state dictionary for the child
	states[state_name] = states.size()
	
