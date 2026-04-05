extends TextureButton


func _ready() -> void:
	pressed.connect(Transition.change_scene_path.bind('res://ui/main_menu/main_menu.tscn'))
