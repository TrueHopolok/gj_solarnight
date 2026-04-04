extends Node2D


@onready var button_mirror_r: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonMirrorR
@onready var button_mirror_l: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonMirrorL
@onready var button_split_r: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitR
@onready var button_split_l: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitL
@onready var button_split_b: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitB
@onready var button_split_u: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonSplitU
@onready var button_lightbulb: Button = $CanvasLayer/ScrollContainer/HBoxContainer/ButtonLightbulb

@onready var builder: Builder = $Builder


func _ready() -> void:
	button_mirror_r.pressed.connect(builder.select_building.bind(0))
	button_mirror_l.pressed.connect(builder.select_building.bind(1))
	button_split_r.pressed.connect(builder.select_building.bind(2))
	button_split_l.pressed.connect(builder.select_building.bind(3))
	button_split_b.pressed.connect(builder.select_building.bind(4))
	button_split_u.pressed.connect(builder.select_building.bind(5))
	button_lightbulb.pressed.connect(builder.select_building.bind(6))
