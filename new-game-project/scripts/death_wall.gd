extends Node2D

const BASE_SPEED = 100.0

var player: CharacterBody2D

@onready var kill_area: Area2D = $Area2D


func _ready() -> void:
	kill_area.body_entered.connect(_on_body_entered)


func initialize(p: CharacterBody2D) -> void:
	player = p


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing:
		return
	
	var speed = BASE_SPEED * GameManager.difficulty
	position.x += speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.die()
