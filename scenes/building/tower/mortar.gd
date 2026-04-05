extends Tower


@export var color_reload := Color.ORANGE_RED
@export var color_ready := Color.LIME

@onready var aim_sprite: Sprite2D = $Aim

var _mouse_inside: bool = false
var _is_targeting: bool = false


func _mouse_enter() -> void:
	_mouse_inside = true


func _mouse_exit() -> void:
	_mouse_inside = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"mortar_target"):
		if _is_targeting:
			shoot()
			get_viewport().set_input_as_handled()
		elif _mouse_inside:
			_start_aiming()
			get_viewport().set_input_as_handled()

	elif event.is_action_pressed(&"mortar_cancel") and _is_targeting:
		_cancel_aiming()
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	super(delta)
	if _is_targeting:
		aim_sprite.modulate = _get_color()
		aim_sprite.global_position = get_global_mouse_position()
		queue_redraw()


func _draw() -> void:
	if _is_targeting:
		var target := get_local_mouse_position()
		var mid := target * clampf(remap(_reload_left, 0, reload_time, 1, 0), 0, 1)

		draw_dashed_line(Vector2.ZERO, mid, color_ready, 5)
		draw_dashed_line(mid, target, color_reload, 5)


func _start_aiming() -> void:
	queue_redraw()
	_is_targeting = true
	aim_sprite.show()


func _cancel_aiming() -> void:
	queue_redraw()
	_is_targeting = false
	aim_sprite.hide()


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
	inst.set(&"global_position", get_global_mouse_position())
	_cancel_aiming()


func _track_target() -> void:
	if _is_targeting:
		_look_at(get_global_mouse_position())
