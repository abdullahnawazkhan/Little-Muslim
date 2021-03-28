extends KinematicBody2D

onready var particles := get_node("Particles2D")

const SPELL_SPEED = 200
const ATTACK_POWER = 15

var direction

func init(d) -> void:
	self.direction = d
	
	

func _on_Area2D_body_entered(body: Node) -> void:
	if (body.get_name() == "player"):
		body.get_hurt(ATTACK_POWER)
		queue_free()


func _process(delta: float) -> void:
	if direction == "right":
		particles.rotation_degrees = -180.0
	else:
		particles.rotation_degrees = 0.0
		
	var motion
	
	if direction == "right":
		motion = Vector2(1, 0) * SPELL_SPEED
	else:
		motion = Vector2(-1, 0) * SPELL_SPEED
		
	
	self.position += (motion * delta)
	
	if is_on_wall():
		queue_free()

