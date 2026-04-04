@tool
extends EditorScript


func _run() -> void:
	_calculate_shopping_materials()



func _calculate_shopping_materials() -> void:
	const WAVE_MATERIALS: int = 5
	for _wave_numbers: int in 20:
		print(WAVE_MATERIALS * (_wave_numbers + 1))
