extends StaticBody2D


const PROJECTOR_ANGLE: float = 45.0
const ROTATION_SPEED: float = TAU / 3.0

@export var health: int = 100

@onready var projector_visual: Polygon2D = %ProjectorVisual
@onready var building_detector: Area2D = %BuildingDetector
@onready var projector_shape: CollisionPolygon2D = %ProjectorShape

var _dead: bool = false


func _input(event: InputEvent) -> void:
	if OS.is_debug_build() && event.is_action_pressed(&'debug_kys'):
		damage(health)


func _ready() -> void:
	building_detector.body_entered.connect(_set_sun_state.bind(true))
	building_detector.body_exited.connect(_set_sun_state.bind(false))

	const A_LOT: float = 700.0
	var ray := Vector2.RIGHT * A_LOT
	var poly: PackedVector2Array = [
		Vector2.ZERO,
		ray.rotated(deg_to_rad(PROJECTOR_ANGLE * 0.5)),
		ray.rotated(deg_to_rad(-PROJECTOR_ANGLE * 0.5)),
	]

	projector_visual.polygon = poly
	projector_shape.polygon = poly


func _physics_process(delta: float) -> void:
	var inp := Input.get_axis("projector_ccw", "projector_cw")
	building_detector.rotation += inp * ROTATION_SPEED * delta
	projector_visual.global_rotation = building_detector.global_rotation


func _set_sun_state(obj: Node, state: bool) -> void:
	if not obj.has_method(&"set_sun_state"):
		return
	obj.set_sun_state(state)


func damage(dmg: int) -> void:
	if _dead: return
	health -= dmg
	if health <= 0:
		_dead = true
		Persistence.submit()
		$DestroyedSFX.play()
		$BUUUMSFX.play()
		# TODO: gameover animation
		get_tree().create_timer(2.0).timeout.connect(Transition.change_scene_path.bind('res://ui/gameover_menu/gameover_menu.tscn'))


func is_dead() -> bool:
	return _dead
