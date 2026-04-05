extends TextureButton


func _ready() -> void:
	pressed.connect(Transition.change_scene_path.bind('res://scenes/main_game_scene/main_game_scene.tscn'))
