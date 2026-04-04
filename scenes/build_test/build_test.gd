extends Node2D


const TILE_SIZE := Vector2.ONE * 12
const BUILDING_COLLISION_MASK: int = 1

@export var placeables: Array[PackedScene] = []

var _selected_index: int = -1
var _preview_instance: Node2D = null


func _ready() -> void:
	(func ():
		await get_tree().create_timer(2.0).timeout
		select_building(0)
	).call_deferred()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"place_building") and _selected_index != -1:
		get_viewport().set_input_as_handled()
		_try_place(get_local_mouse_position())
	elif event.is_action_pressed(&"delete_building"):
		get_viewport().set_input_as_handled()
		_try_delete(get_local_mouse_position())


func _physics_process(_delta: float) -> void:
	if _selected_index == -1:
		return

	if _preview_instance != null:
		_preview_instance.position = _round_to_cell_center(get_local_mouse_position())


func _try_place(at: Vector2) -> void:
	if _selected_index == -1:
		return

	if _get_scene_at(_world_to_map(at)) != null:
		return # already placed

	var inst := placeables[_selected_index].instantiate()
	inst.position = _round_to_cell_center(at)
	add_child(inst)


func _try_delete(at: Vector2) -> void:
	var inst := _get_scene_at(_world_to_map(at))

	if inst == null:
		return

	if not inst.is_in_group(&"player_built"):
		return

	inst.queue_free()


func _get_scene_at(coord: Vector2i) -> Node:
	var pos := _map_to_world(coord)

	var params := PhysicsPointQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = BUILDING_COLLISION_MASK
	params.position = to_global(pos)
	params.exclude = [_preview_instance]

	var res := get_world_2d().direct_space_state.intersect_point(params, 1)
	if res.is_empty():
		return null

	return res[0].collider


func _round_to_cell_center(pos: Vector2) -> Vector2:
	return _map_to_world(_world_to_map(pos))


func _map_to_world(point: Vector2i) -> Vector2:
	return (Vector2(point) + Vector2.ONE * 0.5) * TILE_SIZE


func _world_to_map(point: Vector2) -> Vector2i:
	return Vector2i(((point - TILE_SIZE * 0.5) / TILE_SIZE).round())



func select_building(idx: int) -> void:
	assert(idx == -1 or (0 <= idx and idx < placeables.size()),
		"select building: index %s with len %s" % [idx, placeables.size()])

	if idx == _selected_index:
		return

	if is_instance_valid(_preview_instance):
		_preview_instance.queue_free()

	_selected_index = idx
	_preview_instance = placeables[idx].instantiate()
	_preview_instance.set_process(false)
	_preview_instance.set_physics_process(false)
	_preview_instance.set_process_input(false)
	_preview_instance.set_process_shortcut_input(false)
	_preview_instance.set_process_unhandled_input(false)
	_preview_instance.set_process_unhandled_key_input(false)
	_preview_instance.modulate.a = 0.5

	_preview_instance.position = _round_to_cell_center(get_local_mouse_position())
	add_child(_preview_instance)


func building_num() -> int:
	return placeables.size()
