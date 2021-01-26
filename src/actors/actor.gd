extends KinematicBody2D
class_name actor

const FLOOR_NORMAL := Vector2.UP

export var gravity := 4000.0
export var speed := Vector2(300.0, 1400.0) 

var _velocity := Vector2.ZERO
