extends Control

signal word_completed

const FALLBACK_WORDS: Array[String] = [
	"jump", "leap", "dash", "bolt", "fly",
	"hop", "sprint", "vault", "skip", "run",
	"rush", "zoom", "soar", "fling", "bound"
]

const HARD_WORDS: Array[String] = [
	"platform", "survive", "escape", "danger",
	"courage", "thunder", "shatter", "cascade"
]

var _current_word = ""
var _typed_so_far = ""
var _active = false

@onready var _word_display: RichTextLabel = $Panel/WordDisplay
@onready var _hint_label: Label = $Panel/HintLabel
@onready var _http: HTTPRequest = HTTPRequest.new()


func _ready() -> void:
	add_child(_http)
	_http.request_completed.connect(_on_request_done)
	visible = false
	set_process_input(false)


func request_word() -> void:
	_typed_so_far = ""
	visible = true
	_hint_label.text = "Fetching word…"
	_word_display.text = ""
	
	var length = 6 if GameManager.difficulty >= 2.5 else (5 if GameManager.difficulty >= 1.5 else 4)
	var url = "https://random-word-api.herokuapp.com/word?number=1&length=%d" % length
	
	var err = _http.request(url)
	if err != OK:
		_use_fallback()


func _on_request_done(result: int, code: int, _headers, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_use_fallback()
		return
	
	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		_use_fallback()
		return
	
	var data = json.get_data()
	if data is Array and data.size() > 0 and data[0] is String:
		_activate_word(data[0].to_lower())
	else:
		_use_fallback()


func _use_fallback() -> void:
	var pool = HARD_WORDS if GameManager.difficulty >= 2.0 else FALLBACK_WORDS
	_activate_word(pool[randi() % pool.size()])


func _activate_word(word: String) -> void:
	_current_word = word
	_typed_so_far = ""
	_active = true
	_hint_label.text = "Type the word to jump!"
	_refresh_display()
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if not _active or not GameManager.is_playing:
		return
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.unicode <= 0:
		return
	
	var ch = char(event.unicode).to_lower()
	if ch < "a" or ch > "z":
		return
	
	if _typed_so_far.length() < _current_word.length():
		if ch == _current_word[_typed_so_far.length()]:
			_typed_so_far += ch
			_refresh_display()
			
			if _typed_so_far == _current_word:
				_finish()
		else:
			_typed_so_far = ""
			_flash_error()
			_refresh_display()


func _refresh_display() -> void:
	var typed_part = "[color=#66ff88]%s[/color]" % _typed_so_far
	var remaining = _current_word.substr(_typed_so_far.length())
	var remain_part = "[color=#cccccc]%s[/color]" % remaining
	
	_word_display.text = "[center][font_size=52]%s%s[/font_size][/center]" % [typed_part, remain_part]


func _flash_error() -> void:
	var panel = $Panel
	var tween = create_tween()
	tween.tween_property(panel, "modulate", Color(1, 0.2, 0.2), 0.05)
	tween.tween_property(panel, "modulate", Color.WHITE, 0.1)


func _finish() -> void:
	_active = false
	visible = false
	set_process_input(false)
	
	GameManager.add_score(_current_word.length() * 15)
	word_completed.emit()
