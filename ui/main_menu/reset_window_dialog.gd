extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(Persistence.reset)
