extends Node


const CFG_PATH: String = "user://settings.cfg"

var config: ConfigFile


func _init() -> void:
	config = ConfigFile.new()
	var err: Error = config.load(CFG_PATH)
	if err != Error.OK && err != Error.ERR_FILE_NOT_FOUND: print("Error reading settings config: ", err)


func is_touchscreen() -> bool:
	var n := OS.get_name()
	return n == "Android" or n == "iOS" or OS.has_feature("touch")
