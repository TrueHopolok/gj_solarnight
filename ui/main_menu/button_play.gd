extends TextureButton


func _ready() -> void:
	pressed.connect(
		func() -> void:
			get_tree().paused = true
			$PressSFX.play()
			$PressSFX.finished.connect(Transition.change_scene_path.bind('res://scenes/main_game_scene/main_game_scene.tscn'))
	)
