extends TextureButton


func _ready() -> void:
	pressed.connect(func()->void: get_tree().paused = true)


func _process(_delta: float) -> void:
	visible = !get_tree().paused
