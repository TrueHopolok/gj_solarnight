extends TextureButton


func _ready() -> void:
	pressed.connect($ReturnConfirmationWindow.show)
