class_name GameManager

extends Node

@onready var _main_game_scene: Node2D = get_tree().get_first_node_in_group('main_game_scene')
@onready var _sun: Node2D = get_tree().get_first_node_in_group('sun')

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

var _enemy_spawn_queue: Array[SpawnItem]

const ENEMY_BLIMP_WAVE: int = 15
const ENEMY_SHIELD_WAVE: int = 10

var _enemy_shop: Array[EnemyItem] = [
	## Fodder (increased spawn priority)
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),
	EnemyItem.new(1, 2, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn')]),

	## Shooter (increased spawn priority)
	EnemyItem.new(3, 4, [preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),
	EnemyItem.new(3, 4, [preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),


	# Fodder + Shooter (increased spawn priority)
	EnemyItem.new(5, 5, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),
	EnemyItem.new(5, 5, [preload('res://scenes/enemy/enemy_type/enemy_fodder.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	## Shield
	EnemyItem.new(ENEMY_SHIELD_WAVE, 20, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn')]),

	# Shield + Shooter
	EnemyItem.new(12, 22, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Shield + 2xShooter
	EnemyItem.new(14, 23, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	## Blimp
	EnemyItem.new(ENEMY_BLIMP_WAVE, 75, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),

	# Blimp + Shooter
	EnemyItem.new(16, 77, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# Shield + Blimp
	EnemyItem.new(18, 90, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn'), preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),

	# Blimp + 2xShooter
	EnemyItem.new(20, 78, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn'), preload('res://scenes/enemy/enemy_type/enemy_shooter.tscn')]),

	# 2xBlimp
	EnemyItem.new(25, 130, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn'), preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]),
]


func _enemy_spawn_pos() -> Vector2i:
	var vec: Vector2i
	match randi_range(0, 3):
		0:
			vec = Vector2i(200, randi_range(-90, 90))
		1:
			vec = Vector2i(-200, randi_range(-90, 90))
		2:
			vec = Vector2i(randi_range(140, 200), [-120, 120].pick_random())
		3:
			vec = Vector2i(-randi_range(140, 200), [-120, 120].pick_random())
	return vec


func _enemy_pack_spawn(enemy_pack: Array[PackedScene]) -> void:
	var pos: Vector2i = _enemy_spawn_pos()
	for scene: PackedScene in enemy_pack:
		_enemy_spawn_queue.push_back(SpawnItem.new(pos, scene))
		_wave_enemy_counter += 1
		pos.x = pos.x - 5 if pos.x <= 360 else pos.x + 5


func _enemy_solo_spawn(spawn: SpawnItem) -> void:
	var enemy: Enemy = spawn.scene.instantiate()
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


func wave_get() -> int:
	return _wave_number


func wave_active() -> bool:
	return _wave_enemy_counter > 0


func wave_start() -> void:
	_wave_number += 1
	_wave_enemy_counter = 0

	var shopping_materials: int = max(WAVE_MINIMAL_MATERIALS, _wave_number * WAVE_MATERIALS)
	print("STARTING WAVE: %d  |  sm=%d" % [_wave_number, shopping_materials])

	var enemy_wave_shop: Array[EnemyItem] = _enemy_shop.duplicate()
	enemy_wave_shop.shuffle()
	match _wave_number:
		ENEMY_BLIMP_WAVE:
			enemy_wave_shop.push_front(EnemyItem.new(ENEMY_BLIMP_WAVE, 75, [preload('res://scenes/enemy/enemy_type/enemy_blimp.tscn')]))
		ENEMY_SHIELD_WAVE:
			enemy_wave_shop.push_front(EnemyItem.new(ENEMY_SHIELD_WAVE, 20, [preload('res://scenes/enemy/enemy_type/enemy_shield.tscn')]))


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

signal materials_not_enough
signal materials_spent
signal materials_added

const MATERIALS_START: int = 10

var _materials: int = MATERIALS_START


func _input(event: InputEvent) -> void:
	if OS.is_debug_build() && event.is_action_pressed(&'debug_infitematerials'):
		materials_add(1000000)
		get_viewport().set_input_as_handled()


func materials_get() -> int:
	return _materials


func materials_buy(cost: int) -> bool:
	if (cost == 0): return true
	elif (cost < 0):
		return materials_add(-cost)
	elif (cost > _materials):
		materials_not_enough.emit()
		return false
	_materials -= cost
	materials_spent.emit()
	return true


func materials_add(addition: int) -> bool:
	if (addition == 0): return true
	elif (addition < 0):
		return materials_buy(-addition)
	if (!_sun.is_dead()):
		_materials += addition
		Persistence.current_score += addition
		materials_added.emit()
	return true
