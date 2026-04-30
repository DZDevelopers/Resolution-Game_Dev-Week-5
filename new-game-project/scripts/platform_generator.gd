extends Node2D

const BASE_Y = 500.0
const GAP_MIN = 80.0
const GAP_MAX = 150.0
const W_MIN = 220.0
const W_MAX = 420.0
const LOOK_AHEAD = 1800.0
const CLEAN_BEHIND = 600.0
const HEIGHT_VAR = 50.0

var _platforms = []
var _next_x = 0.0
var _player: Node2D


func initialize(player: Node2D) -> void:
	_player = player
	
	_spawn_platform(800.0, BASE_Y, -300.0)
	_next_x = 500.0
	
	for i in 6:
		_spawn_next()


func _process(_delta: float) -> void:
	if _player == null:
		return
	
	while _next_x < _player.global_position.x + LOOK_AHEAD:
		_spawn_next()
	
	for p in _platforms.duplicate():
		if not is_instance_valid(p):
			_platforms.erase(p)
			continue
		
		var w = p.get_meta("width")
		
		if p.global_position.x + w < _player.global_position.x - CLEAN_BEHIND:
			p.queue_free()
			_platforms.erase(p)


func _spawn_next() -> void:
	var gap = randf_range(GAP_MIN, GAP_MAX)
	var width = randf_range(W_MIN, W_MAX)
	var y = BASE_Y + randf_range(-HEIGHT_VAR, HEIGHT_VAR)
	
	_spawn_platform(width, y, _next_x + gap)
	_next_x += gap + width


func _spawn_platform(width: float, y: float, x: float) -> void:
	var body = StaticBody2D.new()
	body.position = Vector2(x, y)
	body.collision_layer = 1
	body.collision_mask = 0
	body.set_meta("width", width)
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(width, 32)
	shape.shape = rect
	shape.position = Vector2(width / 2.0, 0.0)
	body.add_child(shape)
	
	var visual = ColorRect.new()
	visual.size = Vector2(width, 32)
	visual.position = Vector2(0.0, -16.0)
	visual.color = Color(0.35, 0.55, 0.35)
	body.add_child(visual)
	
	add_child(body)
	_platforms.append(body)
