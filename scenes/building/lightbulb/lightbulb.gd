extends StaticBody2D

@export var color_active: Color
@export var color_inactive: Color

@onready var color_rect: ColorRect = $ColorRect


func _ready() -> void:
	set_light_state(false)


func set_light_state(v: bool) -> void:
	if v:
		color_rect.color = color_active
	else:
		color_rect.color = color_inactive
