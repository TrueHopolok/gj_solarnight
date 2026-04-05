@tool
extends EditorScript


func _run() -> void:
	_calculate_shopping_materials()



func _calculate_shopping_materials() -> void:
	var costs: Array[int] = [
		15,
		10,
		6,
		5,
		5,
		5,
		2,
		2,
		2,
		2,
		2,
	]
	var names: Array[String] = [
		'shield',
		'blimp',
		's+f',
		'shooter',
		'shooter',
		'shooter',
		'fodder',
		'fodder',
		'fodder',
		'fodder',
		'fodder',
	]
	const WAVE_MATERIALS: int = 5
	const WAVE_MINIMAL_MATERIALS: int = 10
	var _wave_number: int = 12
	var shopping_materials: int = max(WAVE_MINIMAL_MATERIALS, (_wave_number - 1) * WAVE_MATERIALS)
	print(_wave_number, ": ", shopping_materials)
	var i: int = 0
	var prev_materials: int = shopping_materials
	while shopping_materials > 0:
		if shopping_materials >= costs[i]:
			shopping_materials -= costs[i]
			print(names[i])
		if i + 1 < costs.size():
			i += 1
		else:
			if prev_materials == shopping_materials: break
			prev_materials = shopping_materials
			i = 0
