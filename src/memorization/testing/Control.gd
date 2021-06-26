extends Control

signal recitation_done

onready var api_text := get_node("api_text/text")
onready var spoken_text := get_node("spoken_text/text")
onready var timer := get_node("get_timer")

onready var start_speaking_btn = get_node("stt_buttons/start_speaking_button")
onready var stop_speaking_btn = get_node("stt_buttons/stop_speaking_button")

onready var error_overlay := get_node("error_overlay")
onready var success_overlay := get_node("success_overlay")
onready var loading_overlay := get_node("loading")

onready var without_diacritics := get_node("without_diacritics_HTTPRequest")
onready var with_diacritics := get_node("with_diacritics_HTTPRequest")

var timer_stopped = false

# object variables of android modules
var speechToText = null
var android = null

# arabic text with diacritics
var arabic = ""
# arabic text spoken by the user
# is received from SpeechToText Android Plugin
var words = ""
# arabic text without diacritics
var simple_arabic = ""

var button_pressed = false

# data provided to constructor as params
var surah_title
var surah
var verse

# in case of multiple verses, storing in arrays
# holds verses without diacritics
var verses_simple = []
# holds verses with diacritics
var verses = []
# current verse number to be shown/processed
var current_verse_index

# new added for testing
# will the number of times the user has failed reciting
var fail_count

# constructor of node
func init(s_title, surah_number, ayat_number) -> void:
	surah_title = s_title
	surah = surah_number
	verse = ayat_number

	current_verse_index = 0
	# new added for testing
	fail_count = 0


func _ready() -> void:
	$loading.visible = true
	
	$title.text = surah_title

	# getting object of SpeechToText Android Plugin
	if Engine.has_singleton("SpeechToText"):
		speechToText = Engine.get_singleton("SpeechToText")
		print("Speech to Text Initialized")
		without_diacritics.request("https://api.quran.com/api/v4/quran/verses/uthmani_simple?chapter_number=" + str(surah))

		with_diacritics.request("https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=" + str(surah))
	else:
		print("Issue with connecting with speech to text android module")


func start_processing():
	# TODO: Bug fix -> Need to handle when user does not say anything
	while true:
		words = speechToText.getWords()
		if (words != ""):
			break
		if timer_stopped == true:
			break
		
	timer.stop()
	timer_stopped = true
	
	if (words == ""):
		error_overlay.visible = true
		loading_overlay.visible = false
	else:
		if (compare(words, simple_arabic) == true):
			# new added for testing
			api_text.arabic_input += arabic + " ۝ "
			
			if verse == 'all':
				if current_verse_index < len(verses):
					# getting next verse from without_diacritics and with_diacritics array
					arabic = verses[current_verse_index]
					simple_arabic = verses_simple[current_verse_index]
					
					current_verse_index = current_verse_index + 1
					$verse.text = "Verse: " + str(current_verse_index)
				else:
					# all verses recited
					emit_signal("recitation_done", 1)
					queue_free()
			else:
				emit_signal("recitation_done", 1)
				queue_free()
			
			$loading.visible = false
			success_overlay.visible = true
		else:
			fail_count += 1
			
			if fail_count == 5:
				api_text.arabic_input = ""
				
				if verse == "all":
					for v in verses:
						api_text.arabic_input += v + " ۝ "
				else:
					api_text.arabic_input = arabic + " ۝ "

				$stt_buttons.visible = false
				$exit.visible = true
				$verse.visible = false
				
			error_overlay.visible = true
			$loading.visible = false


func remove(s, index):
	var new_s = ""
	
	for i in range(len(s)):
		if (i != index):
			new_s += s[i]

	return new_s


func compare(spoken, actual):
	# removing any trailing spaces
	actual = actual.rstrip(' ')
	# removing any leading spaces
	actual = actual.lstrip(' ')

	var i = 0
	while i < spoken.length():
		if (spoken[i] == 'ﻱ' && actual[i] == 'ﻯ' || spoken[i] == 'ﻯ' && actual[i] == 'ﻱ'):
			spoken[i] = actual[i]
			i += 1
			continue
		if (spoken[i] == 'ﻲ' && actual[i] == 'ﻰ' || spoken[i] == 'ﻰ' && actual[i] == 'ﻲ'):
			spoken[i] = actual[i]
			continue
		if (spoken[i] == 'ي' && actual[i] == 'ى' || spoken[i] == 'ى' && actual[i] == 'ي'):
			spoken[i] = actual[i]
			i += 1
			continue
		if (spoken[i] == actual[i]):
			i += 1
			continue
		else:
			spoken = remove(spoken, i)

	if (spoken == actual):
		return true
	else:
		return false


func _on_Timer_timeout() -> void:
	timer.stop()
	timer_stopped = true


func _on_without_diacritics_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code != 200):
		print("Backend Service Error")
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		var data = json.result
		var arr = data["verses"]
		
		var surah_verse
		if verse != 'all':
			surah_verse = str(surah) + ":" + str(verse)
		
		var index = 1
		for a in arr:
			if verse != 'all':
				if a["verse_key"] == surah_verse:
					simple_arabic = a["text_uthmani_simple"]
					break
			else:
				verses_simple.append(a['text_uthmani_simple'])
		
		verses_simple = remove_empty_data(verses_simple)
		verses_simple = remove_diacritics(verses_simple)
		
		if verse == "all":
			simple_arabic = verses_simple[0]

		$loading.visible = false


func _on_with_diacritics_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if (response_code != 200):
		print("Backend Service Error")
	else:
		var json = JSON.parse(body.get_string_from_utf8())
		var data = json.result
		var arr = data["verses"]
		
		var surah_verse
		if verse != 'all':
			surah_verse = str(surah) + ":" + str(verse) # 114:1
			print("Surah_Verse: " + surah_verse)
		
		var index = 1
		for a in arr:
			print("Verse: " + str(index))
			index = index + 1
			if verse != 'all':
				if a["verse_key"] == surah_verse:
					arabic = a["text_uthmani"]
					api_text.arabic_input = arabic
					break
			else:
				verses.append(a['text_uthmani'])
		
		if verse == 'all':
			verses = remove_empty_data(verses)
			arabic = verses[0]
			
			current_verse_index = current_verse_index + 1
			$verse.text = "Verse: " + str(current_verse_index)
		
		$loading.visible = false


func _on_error_cancel_button_pressed() -> void:
	error_overlay.visible = false


func _on_success_cancel_button_pressed() -> void:
	success_overlay.visible = false


func _on_start_speaking_button_pressed() -> void:
	start_speaking_btn.visible = false
	stop_speaking_btn.visible = true

	speechToText.listen()
	words = ""


func _on_stop_speaking_button_pressed() -> void:
	$loading.visible = true
	
	start_speaking_btn.visible = true
	stop_speaking_btn.visible = false
		
	timer_stopped = false

	speechToText.stop()

	timer.set_wait_time(5)
	timer.start()

	words = ""
	
	start_processing()


func remove_diacritics(arr):
	var diacritics_list = ['ؐ', 'ؑ', 'ؒ', 'ؓ', 'ؔ', 'ؕ', 'ؖ', 'ؗ', 'ؘ', 'ؙ', 'ؚ', '؛', 'ً', 'ٌ', 'ٍ', 'َ', 'َ', 'ُ', 'ِ', 'ّ', 'ْ', 'ٓ', 'ٔ', 'ٕ', 'ە', 'ۖ', 'ۗ', 'ۘ', 'ۙ', 'ۚ', 'ۛ', 'ۜ', '۝', '۞', '۟', '۠', 'ۡ', 'ۢ', 'ۢ', 'ۢ', 'ۣ', 'ۤ', 'ۥ', 'ۦ', 'ۧ', 'ۨ', '۩', '۪', '۫', '۬', 'ۭ', 'ٴ', 'ٰ', 'ٔ', 'ٕ', 'ٓ', 'ء']
	var new_arr = []

	for a in arr:
		var new_str = ""
		for i in range(len(a)):
			if diacritics_list.has(a[i]) == false:
				new_str += a[i]
		new_arr.append(new_str)


	return new_arr

func remove_empty_data(arr):
	var new_arr = []
	
	for a in arr:
		if a != '':
			new_arr.append(a)
			
	return new_arr


func _on_exit_button_pressed() -> void:
	emit_signal("recitation_done", 2)
	queue_free()
