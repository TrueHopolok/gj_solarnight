extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(func() -> void: print('reset_progress'))
