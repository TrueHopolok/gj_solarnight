extends Label


func _process(_delta: float) -> void:
	text = "Score: %d" % Persistence.current_score
