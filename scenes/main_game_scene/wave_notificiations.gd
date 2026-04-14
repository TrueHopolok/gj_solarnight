extends Node


func _ready() -> void:
	GameManager.get_instance().wave_started.connect(
		func(_wave_number: int)->void:
			$WaveStartSFX.play()
	)
	GameManager.get_instance().wave_ended.connect(
		func(_wave_number: int)->void:
			$WaveEndSFX.play()
	)
