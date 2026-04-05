extends TextureButton


func _ready() -> void:
	pressed.connect(
		func() -> void:
			get_tree().paused = true
			%StartGameSFX.play()
			%StartGameSFX.finished.connect(
			func() -> void: Transition.change_scene_path('res://scenes/main_game_scene/main_game_scene.tscn')
			)
	)
