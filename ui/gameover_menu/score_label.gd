extends Label


var wave_reached: int = 0


func _ready() -> void:
	text = "Wave reached: %d\nYour score: %d\nBest score: %d" % [wave_reached, Persistence.current_score, Persistence.best_score]
