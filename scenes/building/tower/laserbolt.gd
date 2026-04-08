extends Node2D


const DAMAGE: int = 6

@export_flags_2d_physics var raycast_mask: int = 1
@export_flags_2d_physics var shapecast_mask: int = 1

var target: Node2D = null

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(func (_anim: StringName) -> void:
		queue_free())
	execute.call_deferred()


func execute() -> void:
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

	look_at(end)

	var line2d := $Line2D as Line2D
	line2d.points = [Vector2.ZERO, to_local(end)]

	var shape := RectangleShape2D.new()
	shape.size = Vector2(end.distance_to(global_position), 6)

	var shapecast_params := PhysicsShapeQueryParameters2D.new()
	shapecast_params.collide_with_areas = true
	shapecast_params.collide_with_bodies = true
	shapecast_params.collision_mask = shapecast_mask
	shapecast_params.shape = shape
	shapecast_params.transform = Transform2D(
		(global_position - end).angle(),
		(end + global_position) * 0.5,
	)

	for v: Dictionary in  get_world_2d().direct_space_state.intersect_shape(shapecast_params):
		var obj: Node = v.collider
		if obj.has_method("damage"):
			obj.damage(DAMAGE * 2 if obj.get('week_to_lasers') && obj.week_to_lasers else DAMAGE)
