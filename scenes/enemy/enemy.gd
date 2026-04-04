class_name Enemy

extends CharacterBody2D

signal died(materials_dropped: int)

## 2 hp = 1 cannon
@export var HEALTH: int = 4
## dmg/attack -> 10 / dmg = time for mirror
@export var ATTACK_DAMAGE: int = 1
## sec/attack
@export var ATTACK_COOLDOWN: float = 1.0
## px/sec -> 320 / speed = time
@export var MOVEMENT_SPEED: float = 100.0
## materials/death
@export var MATERIALS_DROPPED: int = 1
## go straight for the sun
@export var IGNORE_BULIDINGS: bool = false

@onready var _sun: Node2D = get_tree().get_first_node_in_group('sun')
@onready var _proj_scene: PackedScene = preload('res://scenes/enemy/enemy_projectile/enemy_projectile.tscn')
@onready var _main_game_scene: Node2D = get_tree().get_first_node_in_group('main_game_scene')

var _attack_cooldown: float = 0.0


func _input(event: InputEvent) -> void:
	if OS.is_debug_build() && event.is_action_pressed(&'debug_killall'):
		damage(HEALTH)


func _physics_process(delta: float) -> void:
	_attack_cooldown = max(0.0, _attack_cooldown - delta)
	if $AgroArea.has_overlapping_bodies():
		if IGNORE_BULIDINGS:
			var found_sun: bool = false
			for body: Node2D in $AgroArea.get_overlapping_bodies():
				if body.is_in_group('sun'):
					found_sun = true
					break
			if found_sun:
				if _attack_cooldown <= 0.0:
					_attack()
				velocity = Vector2.ZERO
				move_and_slide()
				return
		else:
			if _attack_cooldown <= 0.0:
				_attack()
			velocity = Vector2.ZERO
			move_and_slide()
			return
	velocity = global_position.direction_to(_sun.global_position) * MOVEMENT_SPEED
	move_and_slide()
	$AgroArea.rotation = (global_position - _sun.global_position).angle()


func _attack() -> bool:
	_attack_cooldown = ATTACK_COOLDOWN
	var closest_body: StaticBody2D
	var closest_dist: float = INF
	for body: Node2D in $AgroArea.get_overlapping_bodies():
		if IGNORE_BULIDINGS && !body.is_in_group('sun'):
			continue
		var dist: float = global_position.distance_squared_to(body.global_position)
		if dist < closest_dist:
			closest_body = body
			closest_dist = dist
	if closest_dist == INF:
		return false
	var proj: EnemyProjectile = _proj_scene.instantiate()
	proj.global_position = global_position
	proj.dmg = ATTACK_DAMAGE
	proj.dir = global_position.direction_to(closest_body.global_position)
	_main_game_scene.add_child(proj)
	return true


func damage(dmg: int) -> void:
	HEALTH -= dmg
	if HEALTH <= 0:
		# TODO: show death
		died.emit(MATERIALS_DROPPED)
		queue_free()
