extends Node

signal game_over(final_score: int)

var score: int = 0
var is_playing: bool = false
var difficulty: float = 1.0

var _diff_timer: float = 0.0


func _process(delta: float) -> void:
	if not is_playing:
		return
	
	_diff_timer += delta
	
	if _diff_timer >= 10.0:
		_diff_timer = 0.0
		difficulty = min(difficulty + 0.2, 3.5)
		add_score(100)


func start_game() -> void:
	score = 0
	difficulty = 1.0
	_diff_timer = 0.0
	is_playing = true


func end_game() -> void:
	if not is_playing:
		return
	
	is_playing = false
	game_over.emit(score)


func add_score(points: int) -> void:
	score += points
