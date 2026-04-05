class_name GameManager

extends Node

@onready var _main_game_scene: Node2D = get_tree().get_first_node_in_group('main_game_scene')

var _time_after_spawn: float = 0.0

static func get_instance() -> GameManager:
	return Engine.get_main_loop().get_first_node_in_group('game_manager')

func _physics_process(delta: float) -> void:
	_time_after_spawn += delta
	if _time_after_spawn >= ENEMY_SPAWN_INTERVAL:
		_time_after_spawn = 0.0
		if _enemy_spawn_queue.is_empty():
			return
		_enemy_solo_spawn(_enemy_spawn_queue.pop_back())


#####################
### ENEMY MANAGER ###

const ENEMY_SPAWN_INTERVAL: float = 0.2

const ENEMY_BOSS_MIN_COST: int = 20
const ENEMY_COMBO_MIN_COST: int = 100
const ENEMY_DUO_MIN_COST: int = 10

const ENEMY_BOSS_STARTING_WAVE: int = 10
const ENEMY_COMBO_STARTING_WAVE: int = 5
const ENEMY_DUO_STARTING_WAVE: int = 5

var _enemy_spawn_queue: Array[SpawnItem]

var _enemy_shop: Array[EnemyItem] = [
	## SOLO:

	# Fodder (increased spawn priority)
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),

	# Shooter (increased spawn priority)
	EnemyItem.new(3, 5, [preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),
	EnemyItem.new(3, 5, [preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Blimp
	EnemyItem.new(5, 10, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),

	# Shield
	EnemyItem.new(10, 15, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn')]),

	## DUO:

	# Fodder + Shooter (increased spawn priority)
	EnemyItem.new(4, 6, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),
	EnemyItem.new(4, 6, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Blimp + Shooter
	EnemyItem.new(7, 12, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Shield + Shooter
	EnemyItem.new(12, 17, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Shield + Blimp
	EnemyItem.new(15, 20, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),

	## COMBO:

	# Blimp + 2xShooter
	EnemyItem.new(9, 13, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Shield + 2xShooter
	EnemyItem.new(14, 18, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# 2xShield + 2xBlimp
	EnemyItem.new(20, 18, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),
]


func _enemy_spawn_pos() -> Vector2i:
	var vec: Vector2i
	match randi_range(0, 2):
		0:
			vec = Vector2i(randi_range(-40, -30), randi_range(-30, 390))
		1:
			vec = Vector2i(randi_range(670, 680), randi_range(-30, 390))
		2:
			vec = Vector2i(randi_range(-30, 50), [randi_range(-40, -30), randi_range(390, 400)].pick_random())
	vec -= Vector2i(320, 180)
	return vec


func _enemy_pack_spawn(enemy_pack: Array[PackedScene]) -> void:
	var pos: Vector2i = _enemy_spawn_pos()
	for scene: PackedScene in enemy_pack:
		_enemy_spawn_queue.push_back(SpawnItem.new(pos, scene))
		_wave_enemy_counter += 1
		pos.x = pos.x - 5 if pos.x <= 360 else pos.x + 5


func _enemy_solo_spawn(spawn: SpawnItem) -> void:
	var enemy: Node2D = spawn.scene.instantiate() # TODO add enemy class_name
	enemy.global_position = spawn.pos
	enemy.died.connect(
		func(materials_dropped: int) -> void:
			materials_add(materials_dropped)
			_wave_enemy_counter -= 1
			if _wave_enemy_counter == 0:
				wave_ended.emit(_wave_number)
	)
	_main_game_scene.add_child(enemy)


class SpawnItem:
	var pos: Vector2i
	var scene: PackedScene
	func _init(_pos: Vector2i, _scene: PackedScene) -> void:
		pos = _pos
		scene = _scene


class EnemyItem:
	var starting_wave: int
	var cost: int
	var enemies_pack: Array[PackedScene]
	func _init(_starting_wave: int, _cost: int, _enemies_pack: Array[PackedScene]) -> void:
		starting_wave = _starting_wave
		cost = _cost
		enemies_pack = _enemies_pack


####################
### WAVE MANAGER ###

signal wave_ended(wave_completed: int)

const WAVE_MATERIALS: int = 5
const WAVE_MINIMAL_MATERIALS: int = 10

var _wave_number: int = 0 # important to set as 0, so first wave would be 1
var _wave_enemy_counter: int


func wave_start() -> void:
	_wave_number += 1
	_wave_enemy_counter = 0

	var shopping_materials: int = max(WAVE_MINIMAL_MATERIALS, _wave_number * WAVE_MATERIALS)
	print("STARTING WAVE: %d  |  sm=%d" % [_wave_number, shopping_materials])

	_enemy_shop.shuffle()
	if _wave_number % 5 == 0 && _wave_number >= ENEMY_BOSS_STARTING_WAVE:
		print("this probably should be a boss wave, but we do not have a boss T_T")

	while shopping_materials > 0:
		var prev_shopping_materials: int = shopping_materials

		for enemy: EnemyItem in _enemy_shop:
			if _wave_number < enemy.starting_wave || shopping_materials < enemy.cost:
				continue
			shopping_materials -= enemy.cost
			_enemy_pack_spawn(enemy.enemies_pack)

		if prev_shopping_materials == shopping_materials:
			break

	_enemy_spawn_queue.reverse()


########################
### PLAYER RESOURCES ###

const MATERIALS_START: int = 10

var _materials: int = MATERIALS_START


func materials_get() -> int:
	return _materials


func materials_buy(cost: int) -> bool:
	if (cost > _materials):
		return false
	_materials -= cost
	return true


func materials_add(addition: int) -> bool:
	return materials_buy(-addition)
