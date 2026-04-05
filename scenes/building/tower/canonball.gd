extends AnimatableBody2D


const DAMAGE: int = 3
const SPEED: float = 100.0


var target: Node2D = null


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		queue_free()
		return

	var dir := global_position.direction_to(target.global_position)

	var collision := move_and_collide(dir * SPEED * delta)
	if collision == null:
		return

	var obj: Node2D = collision.get_collider()
	if obj.has_method("damage") and obj.has_method("is_dead") and not obj.is_dead():
		obj.damage(DAMAGE)
		queue_free()
	else:
		add_collision_exception_with(obj)
