extends TextureButton


func _ready() -> void:
	pressed.connect(
		func() -> void:
			get_tree().paused = true
			get_tree().create_timer(2.0).timeout.connect(Transition.change_scene_path.bind('res://scenes/main_game_scene/main_game_scene.tscn'))
	)
