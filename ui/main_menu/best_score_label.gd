extends Label


func _ready() -> void:
	text = "Best score: %d" % Persistence.best_score
