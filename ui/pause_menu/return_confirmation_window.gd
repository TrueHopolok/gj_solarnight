extends ConfirmationDialog


func _ready() -> void:
	confirmed.connect(Transition.change_scene_path.bind('res://ui/main_menu/main_menu.tscn'))
