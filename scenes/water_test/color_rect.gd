extends CanvasItem


@export var scroll_speed1 := Vector2.RIGHT
@export var scroll_speed2 := Vector2.DOWN


@onready var noise1: NoiseTexture2D = (material as ShaderMaterial).get_shader_parameter("noise1")
@onready var noise2: NoiseTexture2D = (material as ShaderMaterial).get_shader_parameter("noise2")


func _process(delta: float) -> void:
	noise1.noise.offset.x += scroll_speed1.x * delta
	noise1.noise.offset.y += scroll_speed1.y * delta
	noise2.noise.offset.x += scroll_speed2.x * delta
	noise2.noise.offset.y += scroll_speed2.y * delta
