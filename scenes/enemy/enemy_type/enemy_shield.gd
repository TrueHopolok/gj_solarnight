extends Enemy


func _ready() -> void:
	super()
	var shield := $Shield as Node2D
	shield.set_flipped(position.x < 0.0)
	shield.position = ($ShieldPosR if position.x < 0.0 else $ShieldPosL).position

	died.connect(func (_materials: int) -> void:
		if is_instance_valid(shield):
			shield.damage(999999999))
