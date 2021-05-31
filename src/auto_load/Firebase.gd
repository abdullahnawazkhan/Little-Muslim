extends Node

var API_KEY = "AIzaSyATfYGkeS78dtFLQ31ZLcTP0Ie1OxadD3k"
var PROJECT_KEY = "little-muslim"

var REGISTER_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=%s" % API_KEY
var LOGIN_ENDPOINT = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=%s" % API_KEY
var FIRESTORE_ENDPOINT = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/" % PROJECT_KEY

var user_token
var user_id
var user_data = {}


func log_in(http, email, password) -> void:
	var body = {
		"email" : email,
		"password" : password,
		"returnSecureToken" : true
	}
	http.request(LOGIN_ENDPOINT, [], false, HTTPClient.METHOD_POST, to_json(body))


func get_headers() -> PoolStringArray:
		return PoolStringArray([
			"Content-Type: application/json",
			"Authorization: Bearer %s" % user_token
		])


func register(http, email, password) -> void:
	var body = {
		"email" : email,
		"password" : password,
	}
	http.request(REGISTER_ENDPOINT, [], false, HTTPClient.METHOD_POST, to_json(body))


func save_document(path, fields, http) -> void:
	var doc = {
		"fields" : fields,
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


func change_password(password, http) -> void:
	var body = {
		"idToken" : user_token,
		"password" : password
	}
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:update?key=%s" % API_KEY
	http.request(url, [], false, HTTPClient.METHOD_POST, to_json(body))
	
	
func forgot_my_password(email, http) -> void:
	var body = {
		"requestType" : "PASSWORD_RESET",
		"email" : email
	}
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=%s" % API_KEY
	http.request(url, [], false, HTTPClient.METHOD_POST, to_json(body))
