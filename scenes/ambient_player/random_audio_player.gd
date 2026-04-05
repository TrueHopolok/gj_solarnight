extends AudioStreamPlayer

@export var _min_delay: float = 15.0
@export var _max_delay: float = 60.0
@export_range(0.0, 0.5, 0.01) var _max_pan: float = 0.3
@export var _audio_streams: Array[AudioStream]
var _effect_panner: AudioEffectPanner


func _ready() -> void:
	var bus_idx: int = AudioServer.get_bus_index(&'SFX_panner')
	_effect_panner = AudioServer.get_bus_effect(bus_idx, 0)
	$Timer.timeout.connect(play_random_sound)
	finished.connect(start_random_delay)
	start_random_delay()


func start_random_delay() -> void:
	$Timer.start(randf_range(_min_delay, _max_delay))


func play_random_sound() -> void:
	var tween = get_tree().create_tween()
	stream = _audio_streams.pick_random()
	tween.tween_property(_effect_panner, ^'pan', randf_range(0.5 - _max_pan, 0.5 + _max_pan), stream.get_length())
	play()
