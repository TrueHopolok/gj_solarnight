extends Node2D


func _ready() -> void:
	GameManager.get_instance().wave_start()
	GameManager.get_instance().wave_ended.connect(GameManager.get_instance().wave_start.unbind(1))
