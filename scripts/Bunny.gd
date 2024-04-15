extends CharacterBody2D


signal ShowDialog
var animated_sprite
var name_label

const FUERZITA_DE_CONEJITO = 2 
const ACCELERATION = 200
const MAX_SPEED = 120
const VERTICAL_SPEED = 75

var ball_rigidbody
var state = State.IDLE
var can_grab = false
var grabbed_offset = Vector2.ZERO
var next_move_time = 0
var timer_running = false
var is_moving = false  # Track movement state
var animation_reset_timer = null
enum State { IDLE, RUN }

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]
var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/idle/idle_bs2d/blend_position",
	"parameters/run/run_bs2d/blend_position"
]

var state_names = {
	State.IDLE: "idle",
	State.RUN: "run"
}

func _ready():
	name_label = $Name_Label
	start_timer()

func _physics_process(delta):
	apply_gravity(delta)
	move_horizontal(delta)
	animate()


func _process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and can_grab:
		position = get_global_mouse_position() + grabbed_offset

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and can_grab:
		print("Bye " + $NameLabel.text +"!!!")
		queue_free()


	# Check if character is moving
	is_moving = velocity.length_squared() > 0

	# Reset animation if not moving
	if !is_moving and state == State.RUN:
		state = State.IDLE

func move_horizontal(delta):
	if !timer_running:
		next_move_time = randi_range(1, 3)
		start_timer()

		var random_action = randi_range(0, 2)
		if random_action == 0:
			move_in_direction(Vector2(1, 0), State.RUN)
		elif random_action == 1:
			move_in_direction(Vector2.ZERO, State.IDLE)
		else:
			move_in_direction(Vector2(-1, 0), State.RUN)

	move_and_slide()

func move_in_direction(direction, animation_state):
	state = animation_state
	apply_movement(direction * ACCELERATION)
	blend_position = direction

func apply_movement(amount) -> void:
	velocity += amount
	velocity = velocity.limit_length(MAX_SPEED)

func apply_gravity(delta):
	if !is_on_floor():
		velocity.y += VERTICAL_SPEED * delta

func animate() -> void:
	var state_name = state_names[state]
	state_machine.travel(state_name)
	animationTree.set(blend_pos_paths[state], blend_position)

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		can_grab = event.pressed
		grabbed_offset = position - get_global_mouse_position()

func start_timer():
	if !timer_running:
		timer_running = true
		await get_tree().create_timer(next_move_time).timeout
		timer_running = false

func change_text(new_name):
	$NameLabel.text = new_name

func change_texture(new_texture):
	$Sprite2D.texture = new_texture
	
func _on_area_2d_body_entered(body):
	if body.has_method("apply_impulse"):
		print("collission")
# Calculate the angle between the bunny and the ball
		var angle = (body.global_position - global_position).angle_to(Vector2.RIGHT)

		# Convert the angle to a direction vector
		var direction = Vector2(cos(angle), sin(angle))

		# Apply the impulse in the calculated direction with the specified strength
		body.apply_impulse(direction * FUERZITA_DE_CONEJITO)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_show_dialog(talk: String):
	print("mostrar diálogo")
	$talking.show_and_hide(7.0,talk)
