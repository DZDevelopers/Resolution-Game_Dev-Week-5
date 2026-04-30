extends CharacterBody2D

enum State { STARTING, RUNNING, WAITING, JUMPING, DEAD }

const MOVE_SPEED = 250.0
const JUMP_FORCE = -800.0
const GRAVITY = 1400.0
const LAND_GRACE = 0.3

var state = State.STARTING
var _land_timer = 0.0

@onready var edge_check: Area2D = $EdgeCheck

signal reached_edge
signal died


func _ready() -> void:
	edge_check.monitoring = true
	edge_check.monitorable = true
	edge_check.collision_mask = 1


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	
	# Apply gravity
	if state == State.JUMPING or not is_on_floor():
		velocity.y += GRAVITY * delta
	elif is_on_floor():
		velocity.y = 0.0
	
	match state:
		State.STARTING:
			velocity.x = 0.0
			if is_on_floor():
				state = State.RUNNING
		
		State.RUNNING:
			_land_timer += delta
			_process_running()
		
		State.WAITING:
			velocity.x = 0.0
		
		State.JUMPING:
			velocity.x = MOVE_SPEED
			if is_on_floor() and velocity.y >= 0.0:
				state = State.RUNNING
				_land_timer = 0.0
	
	move_and_slide()


func _process_running() -> void:
	velocity.x = MOVE_SPEED
	
	if _land_timer >= LAND_GRACE and is_on_floor() and not _has_ground_ahead():
		velocity.x = 0.0
		state = State.WAITING
		reached_edge.emit()


func _has_ground_ahead() -> bool:
	return edge_check.get_overlapping_bodies().size() > 0


func do_jump() -> void:
	if state != State.WAITING:
		return
	
	velocity.y = JUMP_FORCE
	velocity.x = MOVE_SPEED
	state = State.JUMPING


func die() -> void:
	if state == State.DEAD:
		return
	
	state = State.DEAD
	velocity = Vector2.ZERO
	died.emit()
