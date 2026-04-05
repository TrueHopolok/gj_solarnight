extends Node2D


var buildables: BuildList = preload("uid://d32aym1ox3gnq")

@onready var hotbar: HBoxContainer = %Hotbar
@onready var builder: Builder = $Builder
@onready var button_unselect: Button = %ButtonUnselect


func _ready() -> void:
	Persistence.current_score = 0
	GameManager.get_instance().wave_start()
	GameManager.get_instance().wave_ended.connect(GameManager.get_instance().wave_start.unbind(1))

	var i: int = 0
	for item: Buildable in buildables.items:
		var button := Button.new()
		hotbar.add_child(button)
		button.icon = item.preview
		button.pressed.connect(builder.select_building.bind(i))
		i += 1

	button_unselect.pressed.connect(builder.deselect_building)
