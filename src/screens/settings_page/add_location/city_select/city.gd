extends Control

onready var template = get_node("elements/ScrollContainer/VBoxContainer/template")
onready var list = get_node("elements/ScrollContainer/VBoxContainer")

var list_of_countries = []

var id : String

var key = "187be7ece4mshcf1abdb48564025p1804b7jsn0bb1f6390988"

func set_id(country_id) -> void:
	id = country_id
	
func get_headers():
	return PoolStringArray([
		"x-rapidapi-key: %s" % key,
		"x-rapidapi-host: wft-geo-db.p.rapidapi.com",
		"useQueryString: true"
	])

func _on_touch_button_pressed() -> void:
	clear_list()
	$elements/HTTPRequest.request("https://wft-geo-db.p.rapidapi.com/v1/geo/cities?countryIds=" + id + "&namePrefix=" + $elements/searchbar/LineEdit.text, get_headers())
	
	$elements/loading.visible = true


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	var x = parse_json(body.get_string_from_utf8())
	if (response_code == 200):
		var data = parse_json(body.get_string_from_utf8())
		
		for d in data["data"]:
			if d["type"] == "CITY":
				var new_button = template.duplicate()
				new_button.visible = true
				new_button.text = d["city"]
				new_button.connect("pressed", self, "process_choice", [d["city"]])
				
				list.add_child(new_button)
				list_of_countries.append(new_button)
	else:
		print("Server Error")
		$elements/error.visible = true
		
	$elements/loading.visible = false


func clear_list():
	for a in list_of_countries:
		a.queue_free()
	list_of_countries = []


	
func process_choice(name : String) -> void:
	get_parent().set_city(name)
	queue_free()


func _on_TouchScreenButton_pressed() -> void:
	$elements/error.visible = false
