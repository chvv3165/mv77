extends CharacterBody2D

const Weapon := preload("res://scripts/weapon.gd")

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var dash_speed: float = 900.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 1.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var weapon: Node

func _ready() -> void:
	weapon = Weapon.new()
	add_child(weapon)

func _physics_process(delta: float) -> void:
	# Update dash cooldown timer
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Handle dash input
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and not is_dashing:
		start_dash()

	# Handle dash logic
	if is_dashing:
		handle_dash(delta)
	else:
		handle_normal_movement(delta)

	move_and_slide()
	handle_attack_input()

func start_dash() -> void:
	# Get dash direction from input or use facing direction
	var input_direction := Input.get_vector("move_left", "move_right", "ui_up", "ui_down")
	
	if input_direction != Vector2.ZERO:
		dash_direction = input_direction.normalized()
	else:
		# If no input, dash in the direction player was last moving
		dash_direction = Vector2(sign(velocity.x), 0) if velocity.x != 0 else Vector2.RIGHT
	
	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func handle_dash(delta: float) -> void:
	dash_timer -= delta
	
	# Apply dash velocity
	velocity = dash_direction * dash_speed
	
	# End dash when timer expires
	if dash_timer <= 0:
		is_dashing = false
		# Preserve some momentum
		velocity *= 0.5

func handle_normal_movement(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction for left/right movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

func handle_attack_input() -> void:
	if Input.is_action_just_pressed("quick_attack"):
		weapon.quick_attack()
	elif Input.is_action_just_pressed("heavy_attack"):
		weapon.heavy_attack()
	elif Input.is_action_just_pressed("special_attack"):
		weapon.special_attack()
