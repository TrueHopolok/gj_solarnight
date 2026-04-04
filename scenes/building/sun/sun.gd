extends StaticBody2D


@export var health: int = 100


func damage(dmg: int) -> void:
	health -= dmg
	if health <= 0:
		# TODO: gameover animation
		OS.alert("GG")


func is_dead() -> bool:
	return health <= 0
