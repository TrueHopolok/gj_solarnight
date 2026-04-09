extends Tower


signal started_aiming

@export var color_reload := Color.ORANGE_RED
@export var color_ready := Color.LIME

@onready var ready_marker: Sprite2D = $Ready
@onready var aim_sprite: Sprite2D = $Aim

var _mouse_inside: bool = false
var _is_targeting: bool = false


func _mouse_enter() -> void:
	_mouse_inside = true


func _mouse_exit() -> void:
	_mouse_inside = false


func _input(event: InputEvent) -> void:
	if _is_targeting and event.is_action_pressed(&"mortar_target"):
		shoot()
		get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if not _is_targeting and _mouse_inside and event.is_action_pressed(&"mortar_target"):
		_start_aiming()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed(&"deselect") and _is_targeting:
		cancel_aiming()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	super(delta)

	ready_marker.visible = _energry and _reload_left <= 0

	if _is_targeting:
		aim_sprite.modulate = _get_color()
		aim_sprite.global_position = get_global_mouse_position()

		var a := snappedf(global_position.direction_to(get_global_mouse_position()).angle(), TAU / 8)
		ready_marker.position = Vector2.from_angle(a)
		queue_redraw()


func _draw() -> void:
	if _is_targeting:
		var target := get_local_mouse_position()
		var mid := target * clampf(remap(_reload_left, 0, reload_time, 1, 0), 0, 1)

		draw_dashed_line(Vector2.ZERO, mid, color_ready, 1)
		draw_dashed_line(mid, target, color_reload, 1)


func _start_aiming() -> void:
	if _is_targeting:
		return

	queue_redraw()
	_is_targeting = true
	aim_sprite.show()

	started_aiming.emit()



func _get_color() -> Color:
	if _reload_left > 0:
		return color_reload
	return color_ready


func shoot() -> void:
	if _reload_left > 0:
		return

	_reload_left = reload_time
	var inst := projectile.instantiate()
	get_parent().add_child(inst)
	inst.target_pos = get_global_mouse_position()
	inst.global_position = global_position
	$ShootingSfx.play_sfx()
	cancel_aiming()


func _track_target() -> void:
	if _is_targeting:
		_look_at(get_global_mouse_position())


func cancel_aiming() -> void:
	if not _is_targeting:
		return

	queue_redraw()
	_is_targeting = false
	aim_sprite.hide()
