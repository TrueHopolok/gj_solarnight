extends AnimatableBody2D


const FAR_AWAY: float = 600
const DAMAGE: int = 3
const SPEED: float = 100.0
const CANON_MUZZLE = preload("uid://dusg3wghvsm05")


var last_dir: Vector2
var target: Node2D = null


func _ready() -> void:
	var inst := CANON_MUZZLE.instantiate() as Node2D
	get_parent().add_child(inst)
	inst.global_transform = global_transform
	inst.look_at(target.global_position)


func _physics_process(delta: float) -> void:
	if position.length_squared() > FAR_AWAY * FAR_AWAY:
		queue_free()
		return

	if is_instance_valid(target) and not target.is_dead():
		last_dir = global_position.direction_to(target.global_position)
	elif last_dir.is_zero_approx() or target.is_dead():
		queue_free()
		return

	var collision := move_and_collide(last_dir * SPEED * delta)
	if collision == null:
		return

	var obj: Node2D = collision.get_collider()
	if obj.has_method("damage") and obj.has_method("is_dead") and not obj.is_dead():
		obj.damage(DAMAGE)
		queue_free()
	else:
		add_collision_exception_with(obj)
