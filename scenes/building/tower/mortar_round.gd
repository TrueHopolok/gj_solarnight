extends Node2D


const DAMAGE: int = 12
const RADIUS: float = 20.0
const DELAY: float = 0.5

@export_flags_2d_physics var collision_mask: int = 1

var progress: float = 0.0


func _ready() -> void:
	get_tree().create_timer(DELAY).timeout.connect(_execute)


func _draw() -> void:
	if progress <= 0.0:
		return

	var col := Color.RED.lerp(Color.YELLOW, progress)
	draw_circle(Vector2.ZERO, remap(progress, 0, 1, RADIUS, 0), col)



func _process(_delta: float) -> void:
	queue_redraw()


func _execute() -> void:
	var t := create_tween()

	t.tween_property(self, "progress", 1.0, 0.5)
	t.chain().tween_callback(queue_free)


	var shape := CircleShape2D.new()
	shape.radius = RADIUS

	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = collision_mask
	params.shape = shape
	params.transform = global_transform

	var res := get_world_2d().direct_space_state.intersect_shape(params, 128)
	for val: Dictionary in res:
		var obj: Node = val.collider
		if obj.has_method("damage"):
			obj.damage(DAMAGE)
