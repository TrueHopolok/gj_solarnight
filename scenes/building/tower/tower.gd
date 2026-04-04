class_name Tower
extends Node2D


const SUN_MULTIPLIER: float = 1.5

@export var reload_time: float = 3.0
@export var projectile: PackedScene
@export var fire_manually: bool = false


var _reload_left: float
var _energry: bool = false
var _under_sun: bool = false


func _ready() -> void:
	_reload_left = randf_range(reload_time, reload_time * 2)


func _physics_process(delta: float) -> void:
	if not _energry:
		return

	if _under_sun:
		_reload_left -= delta * 1.5
	else:
		_reload_left -= delta

	if _reload_left <= 0:
		if fire_manually:
			_reload_left = 0
		else:
			shoot()


static func pick_target(pos: Vector2) -> Node2D:
	var tree: SceneTree = Engine.get_main_loop()
	var enemies: Array[Node] = tree.get_nodes_in_group(&"enemy")
	if enemies.is_empty():
		return null

	var closest: Node2D = null
	var best_dist := INF

	for enemy: Node2D in enemies:
		if enemy.has_method(&"is_dead") and enemy.is_dead():
			continue
		var dist := enemy.global_position.distance_squared_to(pos)
		if dist < best_dist:
			closest = enemy
			best_dist = dist

	return closest


func shoot() -> void:
	var target: Node2D = pick_target(global_position)
	if target == null:
		return

	_reload_left = reload_time

	var inst := projectile.instantiate()
	get_parent().add_child(inst)
	inst.set(&"global_transform", global_transform)
	inst.set(&"target", target)


func set_sun_state(v: bool) -> void:
	_under_sun = v


func set_light_state(v: bool) -> void:
	_energry = v
