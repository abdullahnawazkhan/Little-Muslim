extends Node

var API_KEY = "AIzaSyATfYGkeS78dtFLQ31ZLcTP0Ie1OxadD3k"
var PROJECT_KEY = "little-muslim"

var REGISTER_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
var LOGIN_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
var FIRESTORE_ENDPOINT = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_KEY

var user_token
var user_id
var user_data = {}



func log_in(http, body) -> void:
	http.request(LOGIN_ENDPOINT, [], false, HTTPClient.METHOD_POST, to_json(body))


func get_headers() -> PoolStringArray:
	return PoolStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % user_token
	])


func register(http, body) -> void:
	http.request(REGISTER_ENDPOINT, [], false, HTTPClient.METHOD_POST, to_json(body))


func save_document(path, fields, http) -> void:
	var doc = {
		"fields" : fields
	}
	var body = to_json(doc)
	var url = FIRESTORE_ENDPOINT + path
	http.request(url, get_headers(), false, HTTPClient.METHOD_POST, body)


func update_document(path, fields, http) -> void:
	var doc = {
		"fields" : fields
	}
	var body = to_json(doc)
	var url = FIRESTORE_ENDPOINT + path
	http.request(url, get_headers(), false, HTTPClient.METHOD_PATCH, body)


func get_document(path, http) -> void:
	var url = FIRESTORE_ENDPOINT + path
	http.request(url, get_headers(), false, HTTPClient.METHOD_GET)
