## This is a separate node to allow drawing trajectory line on another z index.


extends Node2D


@export var color_reload := Color.ORANGE_RED
@export var color_ready := Color.LIME

var progress: float = 0.0


func _draw() -> void:
	var target := get_local_mouse_position()
	var mid := target * clampf(progress, 0, 1)

	draw_dashed_line(Vector2.ZERO, mid, color_ready, 1)
	draw_dashed_line(mid, target, color_reload, 1)


func _process(_delta: float) -> void:
	if visible:
		queue_redraw()
