extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var death_wall: Node2D = $DeathWall
@onready var platform_gen: Node2D = $PlatformGenerator
@onready var camera: Camera2D = $Camera2D
@onready var word_manager: Control = $UI/WordPrompt
@onready var score_label: Label = $UI/ScoreLabel
@onready var game_over_screen: Control = $UI/GameOverScreen
@onready var final_score_label: Label = $UI/GameOverScreen/FinalScoreLabel
@onready var restart_button: Button = $UI/GameOverScreen/RestartButton


func _ready() -> void:
	word_manager.word_completed.connect(player.do_jump)
	
	platform_gen.initialize(player)
	death_wall.initialize(player)
	
	player.reached_edge.connect(_on_player_reached_edge)
	player.died.connect(_on_player_died)
	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_restart)
	
	player.position = Vector2(80, 380)
	death_wall.position.x = player.position.x - 1000.0
	
	camera.position = player.position
	
	GameManager.start_game()


func _process(_delta: float) -> void:
	camera.global_position.x = player.global_position.x
	camera.global_position.y = player.global_position.y - 80
	
	score_label.text = "Score: %d" % GameManager.score


func _on_player_reached_edge() -> void:
	word_manager.request_word()


func _on_player_died() -> void:
	GameManager.end_game()


func _on_game_over(final_score: int) -> void:
	final_score_label.text = "Score: %d" % final_score
	game_over_screen.visible = true


func _restart() -> void:
	get_tree().reload_current_scene()
