extends Control


var thread = Thread.new()
var loaded_scene = null

onready var level_locations = {
	"tutorial" : "res://src/levels/tutorial/tutorial.tscn",
	"forest" : "res://src/levels/forest/forest_a.tscn"
}


func _ready() -> void:
	$Timer.set_wait_time(1.0)
	$Timer.start()
	thread.start(self, "_load", level_locations[PlayerData.user_level])

func _load(path) -> void:
	loaded_scene = load(path)

func _physics_process(delta: float) -> void:
	if (loaded_scene != null):
		get_tree().change_scene_to(loaded_scene)
	else:
		if ($Timer.is_stopped() == true):
			if ($Label.text == "Loading..."):
				$Label.text = "Loading"
			else:
				$Label.text += "." 
			$Timer.set_wait_time(1.0)
			$Timer.start()


func _exit_tree() -> void:
	thread.wait_to_finish()


func _on_Timer_timeout() -> void:
	$Timer.stop()
