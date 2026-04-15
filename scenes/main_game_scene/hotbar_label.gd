extends Label


@onready var _builder: Builder = %Builder


func _process(_delta: float) -> void:
	var idx: int = _builder.get_selected()
	if idx == -1:
		text = "Nothing selected"
		return
	elif idx == -2:
		text = "Destroy building"
		return
	var cur: Buildable = _builder.build_list.items[idx]
	text = "%s - %s, costs %d" % [cur.title, cur.description, cur.price]
