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
## 2x dmg from lasers
@export var week_to_lasers: bool = false

@onready var _sun: Node2D = get_tree().get_first_node_in_group('sun')
@onready var _proj_scene: PackedScene = preload('res://scenes/enemy/enemy_projectile/enemy_projectile.tscn')
@onready var _main_game_scene: Node2D = get_tree().get_first_node_in_group('main_game_scene')
@onready var _sprite_2d: AnimatedSprite2D = $Sprite2D

var _remaining_cooldown: float = 0.0


func _input(event: InputEvent) -> void:
	if OS.is_debug_build() and event.is_action_pressed(&'debug_killall'):
		damage(_health)


func _ready() -> void:
	if position.x < 0.0:
		$Sprite2D.flip_h = true

	_sprite_2d.animation_finished.connect(func () -> void:
		if _sprite_2d.animation == "death":
			queue_free()
	)

func _physics_process(delta: float) -> void:
	if is_dead():
		return

	_remaining_cooldown = max(0.0, _remaining_cooldown - delta)
	var target: Node2D = _find_target()
	if target:
		if _remaining_cooldown <= 0.0:
			_attack(target)
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = position.direction_to(_sun.position) * _movement_speed
	move_and_slide()
	$AgroArea.rotation = (position - _sun.position).angle()


func _find_target() -> Node2D:
	var closest_body: Node2D = null
	var closest_dist: float = INF
	for body: Node2D in $AgroArea.get_overlapping_bodies():
		if (_ignore_buildings && !body.is_in_group('sun')) || (body.has_method('is_dead') && body.is_dead()):
			continue
		var dist: float = position.distance_squared_to(body.position)
		if dist < closest_dist:
			closest_body = body
			closest_dist = dist
	return closest_body


func _attack(target: Node2D) -> bool:
	_remaining_cooldown = _attack_cooldown

	var proj: EnemyProjectile = _proj_scene.instantiate()
	proj.position = position
	proj.dmg = _attack_damage
	proj.dir = position.direction_to(target.position)
	_main_game_scene.add_child(proj)
	return true


func damage(dmg: int) -> void:
	if is_dead(): return
	_health -= dmg
	if is_dead(): die()


func die() -> void:
	$CollisionShape2D.set_deferred(&"disabled", true)
	_sprite_2d.play(&"death")
	died.emit(_materials_dropped)


func is_dead() -> bool:
	return _health <= 0
