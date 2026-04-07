extends Label


func _ready() -> void:
	text = "Wave reached: %d\nYour score: %d\nBest score: %d" % [Persistence.wave_reached, Persistence.current_score, Persistence.best_score]
