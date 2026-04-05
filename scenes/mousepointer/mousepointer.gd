extends Node

const HAND_NORMAL = preload("uid://fut4smei64t")
const HAND_PRESSED = preload("uid://cdwqyd8ef1qte")


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		Input.set_custom_mouse_cursor(HAND_PRESSED)
	else:
		Input.set_custom_mouse_cursor(HAND_NORMAL)
