class_name ShootingSFX

extends AudioStreamPlayer

@export var MIN_PITCH: float = 0.9
@export var MAX_PITCH: float = 1.1
@export var _audio_streams: Array[AudioStream]


func play_sfx() -> void:
	stream = _audio_streams.pick_random()
	pitch_scale = randf_range(MIN_PITCH, MAX_PITCH)
	play()
