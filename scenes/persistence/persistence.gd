extends Node


var best_score: int = 0
var current_score: int = 0


## load score or set to default
func _init() -> void:
	var file: FileAccess = FileAccess.open('user://bestscore.bin', FileAccess.READ)
	var err: Error = FileAccess.get_open_error()
	if err != OK:
		if err != ERR_FILE_NOT_FOUND:
			printerr("bestscore loading error:", FileAccess.get_open_error())
		return
	best_score = file.get_32()
	file.close()
	current_score = 10
	submit()


## update best score if necessary
func submit() -> void:
	if current_score <= best_score:
		return
	best_score = current_score

	var file: FileAccess = FileAccess.open('user://bestscore.bin', FileAccess.WRITE)
	if FileAccess.get_open_error() != OK:
		printerr("bestscore saving error:", FileAccess.get_open_error())
		return
	file.store_32(best_score)
	file.close()


## resets best score back to 0
func reset() -> void:
	best_score = -1
	current_score = 0
	submit()
	Transition.reload_scene()
