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

const ENEMY_SPAWN_INTERVAL: float = 0.5

const ENEMY_BOSS_MIN_COST: int = 20
const ENEMY_COMBO_MIN_COST: int = 100
const ENEMY_DUO_MIN_COST: int = 10

const ENEMY_BOSS_STARTING_WAVE: int = 5
const ENEMY_COMBO_STARTING_WAVE: int = 5
const ENEMY_DUO_STARTING_WAVE: int = 5

var _enemy_spawn_queue: Array[SpawnItem]

var _enemy_shop: Dictionary[String, Array] = {
	'solo': [
		## SOLO

		# Fodder (cost of 1)
		EnemyItem.new(1, [preload('res://scenes/game_manager/game_manager.tscn')]),

		# Shooter (cost of 2-3)

		# Shield (high cost preferably)

		# Flying (mediun cost)

	],
	'duo': [
		## DUO (cost scales but not as sum, so more expensive are more preferable)

		# Fodder + Shooter

		# Shield + Shooter

		# Shield + Flying

	],
	'combo': [

	],
	'boss': [

	],
}


func _enemy_spawn_pos() -> Vector2i:
	var vec: Vector2i
	match randi_range(0, 3):
		0:
			vec = Vector2i(-30, randi_range(-30, 390))
		1:
			vec = Vector2i(670, randi_range(-30, 390))
		2:
			vec = Vector2i(randi_range(-30, 670), -30)
		3:
			vec = Vector2i(randi_range(-30, 670), 390)
	return vec


func _enemy_pack_spawn(enemies: Array[PackedScene]) -> void:
	var spawn_pos: Vector2i = _enemy_spawn_pos()
	for enemy_scene: PackedScene in enemies:
		_enemy_spawn_queue.push_back(SpawnItem.new(spawn_pos, enemy_scene))
		_wave_enemy_counter += 1


func _enemy_solo_spawn(spawn_item: SpawnItem) -> void:
	var enemy: Node2D = spawn_item.scene.instantiate() # TODO add enemy class_name
	enemy.global_position = spawn_item.pos
	enemy.died.connect(
		func() -> void:
			_wave_enemy_counter -= 1
			if _wave_enemy_counter == 0:
				wave_ended.emit(_wave_number)
	)
	_main_game_scene.add_child(enemy)


class SpawnItem:
	var pos: Vector2i
	var scene: PackedScene
	func _init(spawn_pos: Vector2i, spawn_scene: PackedScene) -> void:
		pos = spawn_pos
		scene = spawn_scene


class EnemyItem:
	var cost: int
	var enemies_pack: Array[PackedScene]
	func _init(enemy_cost: int, loaded_enemies: Array[PackedScene]) -> void:
		cost = enemy_cost
		enemies_pack = loaded_enemies


####################
### WAVE MANAGER ###

signal wave_ended(wave_completed: int)

const WAVE_MATERIALS: int = 5

var _wave_number: int = 0 # important to set as 0, so first wave would be 1
var _wave_enemy_counter: int


func wave_start() -> void:
	_wave_number += 1
	_wave_enemy_counter = 0

	var shopping_materials: int = _wave_number * WAVE_MATERIALS

	var combination: Array[WaveItem] = [
		WaveItem.new('solo', 0, 1),
		WaveItem.new('duo', ENEMY_DUO_STARTING_WAVE, ENEMY_DUO_MIN_COST),
		WaveItem.new('combo', ENEMY_COMBO_STARTING_WAVE, ENEMY_COMBO_MIN_COST)
	]
	combination.shuffle()
	if _wave_number % 5 && _wave_number >= ENEMY_BOSS_STARTING_WAVE:
		combination.insert(0, WaveItem.new('boss', ENEMY_BOSS_STARTING_WAVE, ENEMY_BOSS_MIN_COST))

	while shopping_materials > 0:
		var prev_shopping_materials: int = shopping_materials

		for wave_item: WaveItem in combination:
			if _wave_number < wave_item.starting_wave || shopping_materials < wave_item.min_cost:
				continue
			_enemy_shop[wave_item.type_name].shuffle()
			for enemy_item: EnemyItem in _enemy_shop[wave_item.type_name]:
				if enemy_item.cost > shopping_materials:
					continue
				shopping_materials -= enemy_item.cost
				_enemy_pack_spawn(enemy_item.enemies_pack)
		_enemy_spawn_queue.reverse()

		if prev_shopping_materials == shopping_materials:
			break


class WaveItem:
	var type_name: String
	var starting_wave: int
	var min_cost: int
	func _init(enemy_type: String, first_spawn_wave: int, smallest_enemy_cost: int) -> void:
		type_name = enemy_type
		starting_wave = first_spawn_wave
		min_cost = smallest_enemy_cost


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
