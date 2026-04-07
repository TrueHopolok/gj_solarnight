extends Node2D


const DAMAGE: int = 16
const RADIUS: float = 30.0
const DELAY: float = 1.3

@export_flags_2d_physics var collision_mask: int = 1

var target_pos: Vector2

func _ready() -> void:
	_execute.call_deferred()


func _execute() -> void:
	$MuzzleFlash.play(&"default")

	await get_tree().create_timer(DELAY).timeout

	$Explosion.global_position = target_pos
	$Explosion.play(&"default")

	var shape := CircleShape2D.new()
	shape.radius = RADIUS

	var params := PhysicsShapeQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = collision_mask
	params.shape = shape
	params.transform = $Explosion.global_transform

	var res := get_world_2d().direct_space_state.intersect_shape(params, 128)
	for val: Dictionary in res:
		var obj: Node = val.collider
		if obj.has_method("damage"):
			obj.damage(DAMAGE)

	await $Explosion.animation_finished
	queue_free()
