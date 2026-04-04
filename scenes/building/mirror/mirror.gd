class_name Mirror
extends StaticBody2D


enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

@export var reflection_down: Array[Direction] = []
@export var reflection_up: Array[Direction] = []
@export var reflection_left: Array[Direction] = []
@export var reflection_right: Array[Direction] = []


func redirect_light(inp: Direction) -> Array[Direction]:
	var out: Dictionary[Direction, bool] = {}

	var arr: Array[Direction]
	match inp:
		Direction.DOWN: arr = reflection_down
		Direction.UP: arr = reflection_up
		Direction.LEFT: arr = reflection_left
		Direction.RIGHT: arr = reflection_right

	for dir: Direction in arr:
		out[dir] = true

	return out.keys()
