extends Node

signal namaz_time

var todays_timings = {}


func _process(delta: float) -> void:
	var timeDict = OS.get_time()
	
	if (timeDict.second == 0):
		var hour
		if (timeDict.hour < 10):
			hour = "0" + str(timeDict.hour)
		else:
			hour = str(timeDict.hour)
		
		var minute
		if (timeDict.minute < 10):
			minute = "0" + str(timeDict.minute)
		else:
			minute = str(timeDict.minute)
		
		var time = hour + ":" + minute

		for x in todays_timings:
			if (todays_timings[x] == time):
				emit_signal("namaz_time", x)

