class_name Tower
extends Node2D


const SUN_MULTIPLIER: float = 1.5
const PULSE_TIME: float = 0.2

@export var reload_time: float = 3.0
@export var projectile: PackedScene
@export var fire_manually: bool = false
@export var initial_health: int = 50

var _reload_left: float
var _energry: bool = false
var _under_sun: bool = false
var _health: int

@onready var sun_polygon: Node2D = $SunPolygon
@onready var sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	_reload_left = randf_range(reload_time * 0.5, reload_time * 1.5)
	_health = initial_health

	set_light_state(false)
	set_sun_state(false)

	$PulseTimer.timeout.connect(_pulse)


func _pulse() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^'modulate', Color(1, 0.3, 0.3), PULSE_TIME)
	tween.tween_property(self, ^'modulate', Color(1, 1, 1), PULSE_TIME)
	tween.play()


func _physics_process(delta: float) -> void:
	if not _energry:
		return

	_track_target()

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


## VIRTUAL!
func _track_target() -> void:
	var target := pick_target(global_position)
	if target == null:
		return

	_look_at(-target.global_position)


func _look_at(global_pos: Vector2) -> void:
	var angle := (global_pos - global_position).angle()
	# 0 = right, positive = cw

	angle = wrapf(angle - PI*0.5, 0, TAU)
	# 0 = up, positive = cw

	var idx := roundi(remap(angle, 0, TAU, 0, 8)) % 8
	sprite.frame = idx


func shoot() -> void:
	var target: Node2D = pick_target(global_position)
	if target == null:
		return

	_reload_left = randf_range(reload_time * 0.95, reload_time * 1.05)

	var inst := projectile.instantiate()
	inst.set(&"global_transform", global_transform)
	inst.set(&"target", target)
	get_parent().add_child(inst)
	$ShootingSfx.play_sfx()


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
	if is_dead():
		return
	_health -= val
	if is_dead():
		die()
	elif float(_health) / float(initial_health) <= 0.2 && $PulseTimer.is_stopped():
		$PulseTimer.start()


func is_dead() -> bool:
	return _health <= 0


func die() -> void:
	$CollisionShape2D.call_deferred(&'set_disabled', true)
	$DestroyedSFX.play()
	# TODO: add death animation
	$DestroyedSFX.finished.connect(queue_free)
