extends Sprite2D

func _ready():
	# Hide the sprite when the scene starts
	hide()

func show_and_hide(duration: float,pop_msg):
	
	$DialogLabel.text = pop_msg
	# Show the sprite
	show()

	# Wait for the specified duration in seconds
	await (get_tree().create_timer(duration).timeout)

	# Hide the sprite after the duration
	hide()
