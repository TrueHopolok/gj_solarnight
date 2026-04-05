extends Label


func _ready() -> void:
	text = "Your score: %d\nBest score: %d" % [Persistence.current_score, Persistence.best_score]
