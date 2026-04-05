extends TextureButton

@onready var _gm: GameManager = GameManager.get_instance()


func _ready() -> void:
	pressed.connect(
		func() -> void:
			_gm.wave_start()
			hide()
	)
	_gm.wave_ended.connect(show.unbind(1))
