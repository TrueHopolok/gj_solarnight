extends Node2D


const DAMAGE: int = 4

@export_flags_2d_physics var raycast_mask: int = 1
@export_flags_2d_physics var shapecast_mask: int = 1

var target: Node2D = null


func _ready() -> void:
	execute.call_deferred()


func execute() -> void:
	queue_free()

	const A_LOT: float = 700

	var raycast_params := PhysicsRayQueryParameters2D.new()
	raycast_params.collide_with_areas = true
	raycast_params.collide_with_bodies = true
	raycast_params.collision_mask = raycast_mask
	raycast_params.from = global_position
	raycast_params.to = global_position + global_position.direction_to(target.global_position) * A_LOT
	raycast_params.hit_from_inside = true

	var res := get_world_2d().direct_space_state.intersect_ray(raycast_params)
	var end := raycast_params.to

	if not res.is_empty():
		end = res.position


	var line2d := Line2D.new()
	line2d.width = 6
	line2d.points = [global_position, end]
	line2d.default_color = Color.RED
	get_parent().add_child(line2d)

	var t := line2d.create_tween()
	t.tween_property(line2d, "modulate:a", 0.0, 0.5).from(1.0)
	t.chain().tween_callback(line2d.queue_free)

	var line_shape := SegmentShape2D.new()
	line_shape.a = global_position
	line_shape.b = end

	var shapecast_params := PhysicsShapeQueryParameters2D.new()
	shapecast_params.collide_with_areas = true
	shapecast_params.collide_with_bodies = true
	shapecast_params.collision_mask = shapecast_mask
	shapecast_params.shape = line_shape
	shapecast_params.transform = Transform2D.IDENTITY

	for v: Dictionary in  get_world_2d().direct_space_state.intersect_shape(shapecast_params):
		var obj: Node = v.collider
		if obj.has_method("damage"):
			obj.damage(DAMAGE)
