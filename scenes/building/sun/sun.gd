extends StaticBody2D


signal died

const PULSE_TIME: float = 0.2
const PROJECTOR_ANGLE: float = 60
const ROTATION_SPEED: float = TAU / 3.0

@export var initial_health: int = 100

@onready var projector_visual: Polygon2D = %ProjectorVisual
@onready var building_detector: Area2D = %BuildingDetector
@onready var projector_shape: CollisionPolygon2D = %ProjectorShape
@onready var health: int = initial_health

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

	$FastestPulseTimer.timeout.connect(_pulse)
	$FastPulseTimer.timeout.connect(_pulse)
	$SlowPulseTimer.timeout.connect(_pulse)


func _physics_process(delta: float) -> void:
	var inp := Input.get_axis("projector_ccw", "projector_cw")
	building_detector.rotation += inp * ROTATION_SPEED * delta
	projector_visual.global_rotation = building_detector.global_rotation


func _pulse() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, ^'modulate', Color(1, 0.3, 0.3), PULSE_TIME)
	tween.tween_property(self, ^'modulate', Color(1, 1, 1), PULSE_TIME)
	tween.play()


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
		$Base.hide()
		$Top.hide()
		$Explosion.play("default")
		$ProjectorVisual.hide()
		died.emit()
		await $Explosion.animation_finished
		get_tree().create_timer(1.0).timeout.connect(_change_to_gameover)
	elif float(health) / float(initial_health) <= 0.1:
		if $FastestPulseTimer.is_stopped():
			$SlowPulseTimer.stop()
			$FastPulseTimer.stop()
			$FastestPulseTimer.start()
			_pulse()
	elif float(health) / float(initial_health) <= 0.3:
		if $FastPulseTimer.is_stopped():
			$SlowPulseTimer.stop()
			$FastPulseTimer.start()
			$FastestPulseTimer.stop()
			_pulse()
	elif float(health) / float(initial_health) <= 0.5:
		if $SlowPulseTimer.is_stopped():
			$SlowPulseTimer.start()
			$FastPulseTimer.stop()
			$FastestPulseTimer.stop()
			_pulse()


func is_dead() -> bool:
	return _dead


func _change_to_gameover() -> void:
	var gameover: Node = load('res://ui/gameover_menu/gameover_menu.tscn').instantiate()
	gameover.get_node("ScoreLabel").wave_reached = GameManager.get_instance().wave_get()
	Transition.change_scene_instance(gameover)
