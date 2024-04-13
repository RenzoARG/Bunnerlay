extends CharacterBody2D

const ACCELERATION = 5000
const FRICTION = 1000
const MAX_SPEED = 150
const VERTICAL_SPEED = 100
@onready var collision_shape = $CollisionShape2D as CollisionShape2D  # Assuming your CollisionShape node is named 
enum {IDLE, RUN}
var state = IDLE

# grabbing vars
var can_grab = false
var grabbed_offset = Vector2()
# grabbing vars

#standalone movement vars
var timer_running = false
var next_move_time = 0
var is_falling = false  # Track if the character is falling
#standalone movement vars

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/idle/idle_bs2d/blend_position",
	"parameters/run/run_bs2d/blend_position"
]
var animTree_state_keys = [
	"idle",
	"run"
]

func _ready():
	next_move_time = randi_range(1, 3)
	start_timer()

func _physics_process(delta):
	move_horizontal(delta)
	animate()

func _process(delta):
	check_vertical_movement(delta)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_grab:
		position = get_global_mouse_position() + grabbed_offset

func move_horizontal(delta):
	if is_falling:
		return  # Don't apply horizontal movement while falling

	if !timer_running:
		next_move_time = randi_range(1, 3)
		start_timer()

		var random_action = randi_range(0, 2)
		match random_action:
			0:
				var random_direction = Vector2(1, 0)  # Random horizontal direction
				state = RUN
				apply_movement(random_direction * ACCELERATION * delta)
				blend_position = random_direction
			1:
				state = IDLE
				apply_friction(FRICTION * delta)
				blend_position = Vector2.ZERO
			2:
				var random_direction = Vector2(-1, 0)  # Random horizontal direction
				state = RUN
				apply_movement(random_direction * ACCELERATION * delta)
				blend_position = random_direction

	move_and_slide()

func check_vertical_movement(delta):
	var colliding_areas = collision_shape.get_overlapping_areas()  # Check for overlapping areas
	if colliding_areas.size() == 0:
		is_falling = true
		position.y += delta * VERTICAL_SPEED  # Apply gravity
	else:
		is_falling = false  # Reset falling state when grounded

func apply_movement(amount) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func apply_friction(amount) -> void:
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func animate() -> void:
	state_machine.travel(animTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()

func start_timer():
	timer_running = true
	await get_tree().create_timer(next_move_time).timeout
	timer_running = false
