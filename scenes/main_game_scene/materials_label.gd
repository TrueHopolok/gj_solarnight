extends Label

const PULSE_TIME: float = 0.2

@onready var _gm: GameManager = GameManager.get_instance()
var _tween: Tween


func _ready() -> void:
	_gm.materials_not_enough.connect(_pulse_not_enough)
	_gm.materials_spent.connect(_pulse_spent)
	_gm.materials_added.connect(_pulse_added)


func _process(_delta: float) -> void:
	text = "Materials: %d" % _gm.materials_get()


func _pulse_added() -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(self, ^'modulate', Color(0, 1, 0), PULSE_TIME)
	_tween.tween_property(self, ^'modulate', Color(1, 1, 1), PULSE_TIME)


func _pulse_spent() -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_property(self, ^'modulate', Color(1, 0, 0), PULSE_TIME)
	_tween.tween_property(self, ^'modulate', Color(1, 1, 1), PULSE_TIME)


func _pulse_not_enough() -> void:
	if _tween:
		_tween.kill()
	$NotEnoughSFX.play()
	_tween = get_tree().create_tween()
	_tween.tween_property(self, ^'modulate', Color(1, 0, 0), PULSE_TIME)
	_tween.tween_property(self, ^'modulate', Color(1, 1, 1), PULSE_TIME)
