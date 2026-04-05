class_name EnemyShield
extends AnimatableBody2D


## 3 hp = 1 cannon
var _health: int = 200

@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_player.animation_finished.connect(func(anim: StringName) -> void:
		if anim == &"death":
			queue_free()
	)


func damage(dmg: int) -> void:
	_health -= dmg
	if _health <= 0:
		$CollisionShape2D.set_deferred(&'disabled', true)
		animation_player.play("death")


func is_dead() -> bool:
	return _health <= 0


func set_flipped(v: bool) -> void:
	sprite_2d.flip_h = v
