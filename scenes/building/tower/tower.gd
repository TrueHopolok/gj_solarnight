class_name Tower
extends Node2D


const SUN_MULTIPLIER: float = 1.5
const SUN_POLYGON_POINTS: int = 30
const SUN_POLYGON_MAJOR: float = 12
const SUN_POLYGON_MINOR: float = 10

@export var reload_time: float = 3.0
@export var projectile: PackedScene
@export var fire_manually: bool = false
@export var initial_health: int = 50

var _reload_left: float
var _energry: bool = false
var _under_sun: bool = false
var _health: int

@onready var sun_polygon: Polygon2D = $SunPolygon


func _ready() -> void:
	_reload_left = randf_range(reload_time, reload_time * 2)
	_health = initial_health

	set_light_state(false)
	set_sun_state(false)

	var polygon: PackedVector2Array
	for i: int in SUN_POLYGON_POINTS:
		polygon.push_back(Vector2.RIGHT.rotated(remap(i, 0, SUN_POLYGON_POINTS, 0, TAU))
			* (SUN_POLYGON_MINOR if i % 2 == 0 else SUN_POLYGON_MAJOR))

	sun_polygon.polygon = polygon


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


func _set_sun_state(v: bool) -> void:
	_under_sun = v
	sun_polygon.visible = _under_sun



func _set_light_state(v: bool) -> void:
	_energry = v
	sun_polygon.visible = _under_sun


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
	if not is_node_ready():
		ready.connect(_set_sun_state.bind(v), CONNECT_ONE_SHOT|CONNECT_REFERENCE_COUNTED)
	else:
		_set_sun_state(v)


func set_light_state(v: bool) -> void:
	if not is_node_ready():
		ready.connect(_set_light_state.bind(v), CONNECT_ONE_SHOT|CONNECT_REFERENCE_COUNTED)
	else:
		_set_light_state(v)


func damage(val: int) -> void:
	_health -= val
	if _health < 0:
		die()


func die() -> void:
	queue_free()
