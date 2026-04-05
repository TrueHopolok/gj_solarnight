extends AudioStreamPlayer

func _ready() -> void:
	get_parent().pressed.connect(play)
