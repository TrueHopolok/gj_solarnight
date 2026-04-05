extends TextureButton


func _ready() -> void:
	pressed.connect(func() -> void: get_tree().paused = false)
