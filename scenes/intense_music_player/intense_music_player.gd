class_name IntenseMusicPlayer

extends Node

const MAX_DISTANCE_SQUARED: float = 120 * 120
const MIN_DISTANCE_SQUARED: float = 20 * 20
const VOLUME_GROWTH_PER_SEC: float = 0.5

@onready var _sun: Node2D = get_tree().get_first_node_in_group('sun')
@onready var _bus_idx: int = AudioServer.get_bus_index(&'Music')
@onready var _effect_idx: int = 0
var _target_volume_linear: float


func _physics_process(delta: float) -> void:
	var dist: float = MAX_DISTANCE_SQUARED
	for enemy: Node2D in get_tree().get_nodes_in_group('enemy'):
		var new_dist: float = _sun.position.distance_squared_to(enemy.position)
		dist = max(min(dist, new_dist), MIN_DISTANCE_SQUARED)
	_target_volume_linear = remap(dist, MAX_DISTANCE_SQUARED, MIN_DISTANCE_SQUARED, 0.0, 1.0)
	if $IntenseMusicPlayer.volume_linear < _target_volume_linear:
		$IntenseMusicPlayer.volume_linear = min($IntenseMusicPlayer.volume_linear + VOLUME_GROWTH_PER_SEC * delta, _target_volume_linear)
	elif $IntenseMusicPlayer.volume_linear > _target_volume_linear:
		$IntenseMusicPlayer.volume_linear = max($IntenseMusicPlayer.volume_linear - VOLUME_GROWTH_PER_SEC * delta, _target_volume_linear)


func _process(_delta: float) -> void:
	AudioServer.set_bus_effect_enabled(_bus_idx, _effect_idx, get_tree().paused)
