class_name DialogArea
extends Control


const CHARS_PER_SECOND: float = 70.0

var _current_seq: Array[DialogLine] = []

@onready var speaker: RichTextLabel = %Speaker
@onready var next: Button = %Next
@onready var content: RichTextLabel = %Content


func _ready() -> void:
	modulate.a = 0


func play_dialog(lines: Array[DialogLine]) -> void:
	if lines.is_empty():
		printerr("Dialog started with no lines, ignoring.")
		return

	_current_seq = lines.duplicate()
	_current_seq.reverse()

	speaker.text = ""
	content.text = ""
	next.disabled = true

	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.5)
	await t.finished

	next.disabled = false

	while not _current_seq.is_empty():
		await _render_line(_current_seq.pop_back())

	next.disabled = true

	t = create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	await t.finished


func _render_line(line: DialogLine) -> void:
	speaker.text = line.speaker
	content.text = line.text
	content.visible_ratio = 0

	var dur := clampf(float(line.text.length()) / CHARS_PER_SECOND, 1, 30)

	var t := create_tween()
	t.tween_property(content, "visible_ratio", 1.0, dur)
	t.chain().tween_callback(next.set.bind("disabled", false))

	var callable := t.custom_step.bind(1e100)
	next.pressed.connect(callable, CONNECT_ONE_SHOT)

	await t.finished
	next.pressed.disconnect(callable)

	await next.pressed
