extends Label


@onready var _builder: Builder = %Builder


func _process(_delta: float) -> void:
	var idx: int = _builder.get_selected()
	if idx == -1:
		text = "Nothing selected"
		return
	var cur: Buildable = _builder.build_list.items[idx]
	text = "%s - %s, %d cost" % [cur.title, cur.description, cur.price]
