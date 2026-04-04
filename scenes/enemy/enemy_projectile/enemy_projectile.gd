class_name EnemyProjectile

extends Area2D

const SPEED: float = 200.0

var dmg: int
var dir: Vector2


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)


func _physics_process(delta: float) -> void:
	global_position += dir * delta * SPEED


func _on_body_entered(body: Node2D) -> void:
	if body.has_method('damage'):
		body.damage(dmg)
		queue_free()
