extends Node2D


const Direction = Mirror.Direction

const TILE_SIZE := Vector2.ONE * 12
const BUILDING_COLLISION_MASK: int = 1
const LIGHT_COLLISION_MASK: int = 2

@export var placeables: Array[PackedScene] = []

var _selected_index: int = -1
var _preview_instance: Node2D = null

var _light_beams: PackedVector2Array

# this is temporary

@onready var button_mirror_r: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonMirrorR
@onready var button_mirror_l: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonMirrorL
@onready var button_split_r: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitR
@onready var button_split_l: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitL
@onready var button_split_b: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitB
@onready var button_split_u: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitU
@onready var button_light: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonLightbulb


func _ready() -> void:
	button_mirror_r.pressed.connect(select_building.bind(0))
	button_mirror_l.pressed.connect(select_building.bind(1))
	button_split_r.pressed.connect(select_building.bind(2))
	button_split_l.pressed.connect(select_building.bind(3))
	button_split_b.pressed.connect(select_building.bind(4))
	button_split_u.pressed.connect(select_building.bind(5))
	button_light.pressed.connect(select_building.bind(6))

	_calculate_light()


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


func _draw() -> void:
	if not _light_beams.is_empty():
		draw_multiline(_light_beams, Color("eaef4a", 0.7), 8, false)


func _try_place(at: Vector2) -> void:
	if _selected_index == -1:
		return

	if _get_scene_at(_world_to_map(at)) != null:
		return # already placed

	var inst := placeables[_selected_index].instantiate()
	inst.position = _round_to_cell_center(at)
	add_child(inst)

	_calculate_light()


func _try_delete(at: Vector2) -> void:
	var inst := _get_scene_at(_world_to_map(at))

	if inst == null:
		return

	if not inst.is_in_group(&"player_built"):
		return

	inst.get_parent().remove_child(inst)
	inst.queue_free()
	_calculate_light()


func _get_scene_at(coord: Vector2i) -> Node:
	var pos := _map_to_world(coord)

	var params := PhysicsPointQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = BUILDING_COLLISION_MASK
	params.position = to_global(pos)
	params.exclude = _extract_rids([_preview_instance])

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


func _calculate_light() -> void:
	_light_beams.clear()

	var visited: Dictionary[Vector3i, bool] = {}
	var lit_nodes: Dictionary[Node, bool] = {}

	_calculate_light_recursive(Vector2i(0, 0), Direction.RIGHT, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(0, 0), Direction.DOWN, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(-1, 0), Direction.DOWN, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(-1, 0), Direction.LEFT, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(-1, -1), Direction.LEFT, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(-1, -1), Direction.UP, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(0, -1), Direction.RIGHT, visited, lit_nodes)
	_calculate_light_recursive(Vector2i(0, -1), Direction.UP, visited, lit_nodes)

	for node: Node in get_tree().get_nodes_in_group(&"light_sensitive"):
		if node == _preview_instance:
			continue

		assert(node.has_method("set_light_state"),
			"node belongs to light_sensitive group but does not have set_light_state")
		if not lit_nodes.has(node):
			node.set_light_state(false)

	queue_redraw()


func _calculate_light_recursive(
	from: Vector2i,
	dir: Direction,
	visited: Dictionary[Vector3i, bool],
	lit_nodes: Dictionary[Node, bool],
) -> void:
	var id := Vector3i(from.x, from.y, dir)
	if visited.has(id):
		return
	visited[id] = true

	const A_LOT: float = 700

	var params := PhysicsRayQueryParameters2D.new()
	params.collide_with_areas = true
	params.collide_with_bodies = true
	params.collision_mask = LIGHT_COLLISION_MASK
	params.exclude = _extract_rids([_preview_instance, _get_scene_at(from)])
	params.hit_from_inside = true
	params.from = _map_to_world(from)
	params.to = params.from + _dir_to_vec(dir) * A_LOT

	var res := get_world_2d().direct_space_state.intersect_ray(params)
	if res.is_empty():
		_light_beams.push_back(params.from)
		_light_beams.push_back(params.to)
		return

	_light_beams.push_back(params.from)
	_light_beams.push_back(_round_to_cell_center(res.position))

	var obj: Node = res.collider

	if obj.has_method(&"set_light_state"):
		obj.set_light_state(true)
		lit_nodes[obj] = true

	if not obj.has_method(&"redirect_light"):
		return

	var start: Vector2i = _world_to_map(obj.position)
	var next: Array[Direction] = obj.redirect_light(_dir_reverse(dir))
	for next_dir: Direction in next:
		_calculate_light_recursive(start, next_dir, visited, lit_nodes)


func _dir_to_vec(dir: Direction) -> Vector2:
	match dir:
		Direction.UP: return Vector2.UP
		Direction.DOWN: return Vector2.DOWN
		Direction.LEFT: return Vector2.LEFT
		Direction.RIGHT: return Vector2.RIGHT
		_: return Vector2.ZERO


func _dir_reverse(dir: Direction) -> Direction:
	match dir:
		Direction.UP: return Direction.DOWN
		Direction.DOWN: return Direction.UP
		Direction.LEFT: return Direction.RIGHT
		Direction.RIGHT: return Direction.LEFT
		_: return dir


func _extract_rids(nodes: Array[CollisionObject2D]) -> Array[RID]:
	var res: Array[RID] = []
	for node: CollisionObject2D in nodes:
		if is_instance_valid(node):
			res.push_back(node.get_rid())
	return res


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
