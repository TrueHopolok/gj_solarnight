extends CanvasLayer


func _process(_delta: float) -> void:
	visible = get_tree().paused


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&'pause_game'):
		get_tree().paused = !get_tree().paused
