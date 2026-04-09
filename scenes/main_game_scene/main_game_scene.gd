extends Node2D


var buildables: BuildList = preload("uid://d32aym1ox3gnq")

var event_to_idx: Dictionary[StringName, int] = {
	&"deselect": -1,

	&"select_canon": 0,
	&"select_laser": 1,
	&"select_mortar": 2,

	&"select_splitter_l": 3,
	&"select_splitter_t": 4,
	&"select_splitter_b": 5,
	&"select_splitter_r": 6,
}

const HOTKEYS: String = "QWE1234"

var idx_to_button: Dictionary[int, Button] = {}

@onready var hotbar: HBoxContainer = %Hotbar
@onready var builder: Builder = $Builder
@onready var button_unselect: Button = %ButtonUnselect
@onready var selector: Control = %Selector


func _ready() -> void:
	Persistence.current_score = 0

	var i: int = 0
	for item: Buildable in buildables.items:
		var button := Button.new()
		hotbar.add_child(button)
		button.text = HOTKEYS[i]
		button.icon = item.preview
		var callable := builder.select_building.bind(i)
		button.pressed.connect(func () -> void:
			callable.call()
		)
		idx_to_button[i] = button
		i += 1

	idx_to_button[-1] = button_unselect

	button_unselect.pressed.connect(builder.deselect_building)
	_update_selector.call_deferred()

	%Sun.died.connect(builder.hide)

	builder.selected_building.connect(func(_building: int) -> void: _update_selector())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"select_next"):
		get_viewport().set_input_as_handled()
		builder.select_next()
		return
	elif event.is_action_pressed(&"select_prev"):
		get_viewport().set_input_as_handled()
		builder.select_prev()
		return

	for event_name: StringName in event_to_idx:
		if event.is_action_pressed(event_name):
			get_viewport().set_input_as_handled()
			builder.select_building(event_to_idx[event_name])
			return


func _update_selector() -> void:
	var idx: int = builder.get_selected()
	var b: Button = idx_to_button[idx]
	var t := selector.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	t.tween_property(selector, "global_position", b.global_position, 0.5)
	t.parallel().tween_property(selector, "size", b.size, 0.5)
