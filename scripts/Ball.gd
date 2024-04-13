extends RigidBody2D

var is_grabbed = false
var target_position = Vector2.ZERO
var move_speed = 5

func _process(delta):
	if is_grabbed:
		var direction = (target_position - global_position).normalized()
		var force = direction * move_speed
		apply_central_impulse(force * delta)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_grabbed = true
				target_position = get_global_mouse_position()
			else:
				is_grabbed = false
