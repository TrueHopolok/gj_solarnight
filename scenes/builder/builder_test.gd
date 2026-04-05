extends Node2D


@onready var builder: Builder = $Builder
@onready var hotbar: HBoxContainer = %Hotbar
@onready var button_unselect: Button = %ButtonUnselect


func _ready() -> void:
	GameManager.get_instance().materials_add(999999999)

	var i: int = 0
	for item: Buildable in builder.build_list.items:
		var button := Button.new()
		hotbar.add_child(button)
		button.icon = item.preview
		button.pressed.connect(builder.select_building.bind(i))
		i += 1

	button_unselect.pressed.connect(builder.deselect_building)
