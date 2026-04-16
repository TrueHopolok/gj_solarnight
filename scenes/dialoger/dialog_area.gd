class_name DialogArea
extends Control


enum State {
	INACTIVE,
	FADE_IN,
	SPEAKING,
	FADE_OUT,
}

const CHARS_PER_SECOND: float = 70.0

@export var king_face: Texture
@export var wizard_face: Texture
@export var nerd_face: Texture

var _current_seq: Array[DialogLine] = []
var _state := State.INACTIVE
var _last_tween: Tween

@onready var speaker: RichTextLabel = %Speaker
@onready var next: Button = %Next
@onready var content: RichTextLabel = %Content
@onready var face: TextureRect = %Face


func _ready() -> void:
	modulate.a = 0
	next.pressed.connect(_on_button)


func _on_tween_finished() -> void:
	_last_tween = null
	match _state:
		State.INACTIVE:
			pass # should be unreachable

		State.FADE_IN:
			# finished fading in, time to start speaking
			if _current_seq.is_empty():
				# start fading out i guess
				_fade_out()
			else:
				_show_line(_current_seq.pop_back())

		State.SPEAKING:
			pass # No action, waiting for user input

		State.FADE_OUT:
			_state = State.INACTIVE
			hide()


func _on_button() -> void:
	match _state:
		State.INACTIVE, State.FADE_IN, State.FADE_OUT:
			pass # Ignore.
		State.SPEAKING:
			# Skip rendering text
			if _last_tween != null and _last_tween.is_valid():
				_last_tween.custom_step(999999)
				_last_tween = null
			elif _current_seq.is_empty():
				_fade_out()
			else:
				_show_line(_current_seq.pop_back())


func play_dialog(lines: Array[DialogLine]) -> void:
	if lines.is_empty():
		printerr("Dialog started with no lines, ignoring.")
		return

	_current_seq = lines.duplicate()
	_current_seq.reverse()
	face.texture = _get_speaker_face(_current_seq.back().speaker)

	show()
	_fade_in()


func _show_line(line: DialogLine) -> void:
	if _last_tween != null:
		_last_tween.kill()
		_last_tween = null

	speaker.text = line.speaker
	
	if SettingsCfg.is_touchscreen() and not line.touchscreen_override_text.is_empty():
		content.text = line.touchscreen_override_text
	else:
		content.text = line.text
	content.visible_ratio = 0
	face.texture = _get_speaker_face(line.speaker)

	var dur := clampf(float(line.text.length()) / CHARS_PER_SECOND, 1, 30)

	var t := create_tween()
	t.tween_property(content, "visible_ratio", 1.0, dur)
	next.disabled = false
	_last_tween = t

	_state = State.SPEAKING


func _fade_in() -> void:
	if _state == State.FADE_IN:
		return

	if _last_tween != null:
		_last_tween.kill()
		_last_tween = null

	speaker.text = ""
	content.text = ""
	next.disabled = true

	var t := create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.5)
	_last_tween = t
	t.finished.connect(_on_tween_finished)

	_state = State.FADE_IN


func _fade_out() -> void:
	if _state == State.FADE_OUT:
		return

	if _last_tween != null:
		_last_tween.kill()
		_last_tween = null

	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	_last_tween = t
	t.finished.connect(_on_tween_finished)

	_state = State.FADE_OUT


func _get_speaker_face(s: String) -> Texture:
	if s.to_lower().contains("king"):
		return king_face
	elif s.to_lower().contains("tutorial"):
		return nerd_face
	return wizard_face
