class_name EnemyShield
extends AnimatableBody2D


## 3 hp = 1 cannon
var _health: int = 90

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D


func damage(dmg: int) -> void:
	_health -= dmg
	if _health <= 0:
		$CollisionShape2D.set_deferred(&'disabled', true)
		# TODO: show death
		queue_free()


func is_dead() -> bool:
	return _health <= 0


func set_flipped(v: bool) -> void:
	sprite_2d.flip_h = v
