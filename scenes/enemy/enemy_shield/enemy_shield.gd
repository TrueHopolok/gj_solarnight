class_name EnemyShield

extends AnimatableBody2D

## 3 hp = 1 cannon
var _health: int = 90

var _dead: bool = false


func damage(dmg: int) -> void:
	_health -= dmg
	if _health <= 0:
		_dead = true
		$CollisionShape2D.set_deferred(&'disabled', true)
		# TODO: show death
		queue_free()


func is_dead() -> bool:
	return _dead
