extends TextureButton


func _ready() -> void:
	pressed.connect(%ResetWindowDialog.show)
