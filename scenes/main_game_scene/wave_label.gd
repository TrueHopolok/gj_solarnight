extends Label

@onready var _gm: GameManager = GameManager.get_instance()


func _process(_delta: float) -> void:
	text = "Wave: %d" % _gm.wave_get()
