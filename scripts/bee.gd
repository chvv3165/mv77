extends CharacterBody2D

@export var fly_speed: float = 150.0
@export var dive_speed: float = 400.0
@export var detection_range: float = 300.0
@export var dive_range: float = 100.0
@export var hover_height: float = 80.0

enum State {
	SEEKING,
	POSITIONING,
	DIVING,
	RECOVERING
}

var player: Node2D
var state: State = State.SEEKING
var dive_target: Vector2
var original_y: float

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		print("No player found.")
	
	original_y = global_position.y
	
func _physics_process(delta: float) -> void:
	if not player:
		return
	
	var distance_to_player := global_position.distance_to(player.global_position)
	
	match state:
		State.SEEKING:
			seek_player(delta, distance_to_player)
		
		State.POSITIONING:
			position_above_player(delta)
		
		State.DIVING:
			dive_attack(delta)
		
		State.RECOVERING:
			recover_to_hover(delta)
	
	move_and_slide()

func seek_player(delta: float, distance: float) -> void:
	# Fly towards player until within detection range
	if distance > detection_range:
		var direction := (player.global_position - global_position).normalized()
		velocity = direction * fly_speed
	else:
		state = State.POSITIONING
		velocity = Vector2.ZERO

func position_above_player(delta: float) -> void:
	# Position above the player for dive attack
	var target_position := Vector2(player.global_position.x, player.global_position.y - hover_height)
	var direction := (target_position - global_position).normalized()
	var distance := global_position.distance_to(target_position)
	
	if distance > 10.0:  # Still moving to position
		velocity = direction * fly_speed
	else:  # In position, prepare to dive
		velocity = Vector2.ZERO
		if global_position.distance_to(player.global_position) <= dive_range:
			state = State.DIVING
			dive_target = player.global_position

func dive_attack(delta: float) -> void:
	# Dive bomb towards the target position
	var direction := (dive_target - global_position).normalized()
	velocity = direction * dive_speed
	
	# Check if we've reached the target or gone past it
	var distance_to_target := global_position.distance_to(dive_target)
	if distance_to_target < 20.0 or global_position.y > dive_target.y + 50:
		state = State.RECOVERING

func recover_to_hover(delta: float) -> void:
	# Return to hovering height and seek player again
	var target_y := player.global_position.y - hover_height
	var target_position := Vector2(global_position.x, target_y)
	
	var direction := (target_position - global_position).normalized()
	var distance := global_position.distance_to(target_position)
	
	if distance > 10.0:
		velocity = direction * fly_speed
	else:
		velocity = Vector2.ZERO
		state = State.SEEKING  # Return to seeking state

# Optional: Visual debug info
func _draw() -> void:
	if Engine.is_editor_hint():
		return
	
	# Draw detection range circle (red)
	draw_arc(Vector2.ZERO, detection_range, 0, TAU, 32, Color.RED, 2.0)
	
	# Draw dive range circle (yellow)
	draw_arc(Vector2.ZERO, dive_range, 0, TAU, 32, Color.YELLOW, 2.0)
