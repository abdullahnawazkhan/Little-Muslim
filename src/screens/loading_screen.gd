# TODO: Implement using ResourceInteractiveLoader
# TODO: Get scene path from mainscreen [Try using autoload to pass data]
extends Control

export(String, FILE) var scene_path := ""
var thread = Thread.new()
var loaded_scene = null

func _get_configuration_warning() -> String:
	if not scene_path:
		return "The next scene property can't be empty"
	else:
		return ""

func _ready() -> void:
	$Timer.set_wait_time(1.0)
	$Timer.start()
	thread.start(self, "_load", scene_path)

func _load(path) -> void:
	loaded_scene = load(path)
	print("I am in the child thread")

func _physics_process(delta: float) -> void:
	if (loaded_scene != null):
		get_tree().change_scene_to(load(scene_path))
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
