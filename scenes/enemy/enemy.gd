class_name Enemy

extends CharacterBody2D

signal died(materials_dropped: int)

## 3 hp = 1 cannon
@export var _health: int = 5
## dmg/attack -> 10 / dmg = time for mirror
@export var _attack_damage: int = 1
## sec/attack
@export var _attack_cooldown: float = 1.0
## px/sec -> 320 / speed = time
@export var _movement_speed: float = 30.0
## materials/death
@export var _materials_dropped: int = 2
## go straight for the sun
@export var _ignore_buildings: bool = false

@onready var _sun: Node2D = get_tree().get_first_node_in_group('sun')
@onready var _proj_scene: PackedScene = preload('res://scenes/enemy/enemy_projectile/enemy_projectile.tscn')
@onready var _main_game_scene: Node2D = get_tree().get_first_node_in_group('main_game_scene')

var _remaining_cooldown: float = 0.0


func _input(event: InputEvent) -> void:
	if OS.is_debug_build() && event.is_action_pressed(&'debug_killall'):
		damage(_health)


func _ready() -> void:
	if position.x < 0.0:
		$Sprite2D.flip_h = true


func _physics_process(delta: float) -> void:
	_remaining_cooldown = max(0.0, _remaining_cooldown - delta)
	if $AgroArea.has_overlapping_bodies():
		if _ignore_buildings:
			var found_sun: bool = false
			for body: Node2D in $AgroArea.get_overlapping_bodies():
				if body.is_in_group('sun'):
					found_sun = true
					break
			if found_sun:
				if _remaining_cooldown <= 0.0:
					_attack()
				velocity = Vector2.ZERO
				move_and_slide()
				return
		else:
			if _remaining_cooldown <= 0.0:
				_attack()
			velocity = Vector2.ZERO
			move_and_slide()
			return
	velocity = position.direction_to(_sun.position) * _movement_speed
	move_and_slide()
	$AgroArea.rotation = (position - _sun.position).angle()


func _attack() -> bool:
	_remaining_cooldown = _attack_cooldown
	var closest_body: StaticBody2D
	var closest_dist: float = INF
	for body: Node2D in $AgroArea.get_overlapping_bodies():
		if _ignore_buildings && !body.is_in_group('sun'):
			continue
		var dist: float = position.distance_squared_to(body.position)
		if dist < closest_dist:
			closest_body = body
			closest_dist = dist
	if closest_dist == INF:
		return false
	var proj: EnemyProjectile = _proj_scene.instantiate()
	proj.position = position
	proj.dmg = _attack_damage
	proj.dir = position.direction_to(closest_body.position)
	_main_game_scene.add_child(proj)
	return true


func damage(dmg: int) -> void:
	_health -= dmg
	if _health <= 0:
		$CollisionShape2D.set_deferred(&'disabled', true)
		# TODO: show death
		died.emit(_materials_dropped)
		queue_free()


func is_dead() -> bool:
	return _health <= 0
