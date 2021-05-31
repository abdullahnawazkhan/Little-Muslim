extends Control

onready var template = get_node("elements/ScrollContainer/VBoxContainer/template")
onready var list = get_node("elements/ScrollContainer/VBoxContainer")

var list_of_countries = []


func _on_touch_button_pressed() -> void:
	clear_list()
	$elements/HTTPRequest.request("http://battuta.medunes.net/api/country/search/?country=" + $elements/searchbar/LineEdit.text + "&key=e63f9251e7b43b868deb085a2d350e03")
	$elements/loading.visible = true

	

func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code == 200):
		var data = parse_json(body.get_string_from_utf8())
		
		for d in data:
			var new_button = template.duplicate()
			new_button.visible = true
			new_button.text = d["name"]
			new_button.connect("pressed", self, "process_choice", [d["name"], d["code"]])
			
			list.add_child(new_button)
			list_of_countries.append(new_button)
		
		$elements/loading.visible = false
	else:
		print("Server Error")


func clear_list():
	for a in list_of_countries:
		a.queue_free()
	
	list_of_countries = []


	
func process_choice(name, code) -> void:
	get_parent().set_country(name, code)
	queue_free()
