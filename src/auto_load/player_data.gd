extends Node2D

signal score_updated
signal player_died
signal player_health_changed

var score := 0 setget set_score
var deaths := 0 setget set_deaths
var health := 100 setget set_health

func reset():
	self.score = 0
	self.deaths = 0
	
func set_score(new_score : int) -> void:
	score = new_score
	emit_signal("score_updated")

func set_deaths(new_value : int) -> void:
	deaths = new_value
	emit_signal("player_died")

func set_health(new_value : int) -> void:
	health = new_value
	emit_signal("player_health_changed")
