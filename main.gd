extends Node
var spawned_bunnies = []
var max_bunnies =10
var bunnies_count = 0
var skins_list = []
var loaded_texture
var channel_name
var ball_instance
var path = "res://resources/sprites/skins/"
var bunny_scene = preload("res://scenes/Bunny.tscn")

var json = JSON.new()
var save_path = "res://config.json"
var data = {}

func _ready():
	var loaded_config = read_save()
	max_bunnies = loaded_config.max_bunnies
	_change_bg_color(loaded_config.bg_color)
	$ball.mass = loaded_config.ball_weight/100
	$ball.physics_material_override.bounce = loaded_config.ball_bounce/100

	var root_node = get_tree().get_root()
	
	VerySimpleTwitch.login_chat_anon(loaded_config.streamer)
	VerySimpleTwitch.chat_message_received.connect(create_chatter_msg)
	skins_list = dir_contents(path)


func write_save(content):
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(content))
	file.close
	file = null

func read_save():
	var file = FileAccess.open(save_path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func create_chatter_msg(chatter: Chatter):
	var container = $playground
	bunnies_count = container.get_child_count()
	if bunnies_count <= max_bunnies:
		#print(chatter.tags.display_name + ": " + chatter.message)
		spawn_mob(chatter.tags.display_name,965,722,load(skins_list[randi() % skins_list.size()]))
		#bunnies_count = bunnies_count + 1
	else:
		print( str(max_bunnies) + " reached")
		remove_random_node_from_container()
		spawn_mob(chatter.tags.display_name,965,722,load(skins_list[randi() % skins_list.size()]))

func _change_bg_color(loaded_color):
	RenderingServer.set_default_clear_color(loaded_color)

func spawn_mob(user_name, pos_x, pos_y, loaded):
	var playground = $playground
	var loaded_name = user_name
	var loaded_texture = loaded
	
	if !playground.has_node(loaded_name):
		var bunnito = bunny_scene.instantiate()
		bunnito.position = Vector2(pos_x, pos_y) # Set the spawn position of the mob
		playground.add_child(bunnito)  # Add the bunny to the container node
		bunnito.name = loaded_name
		bunnito.change_text(user_name)
		bunnito.change_texture(loaded_texture)
	else:
		print("Ya hay un bunito llamado " + loaded_name)
		
		var existing_bunny = playground.get_node(loaded_name)
		var messages = [":)", ":D", "!", "WTF", "!!!", "!?", "🤍", "❤️", "🥕","🔴","🐇"]
		var rand_index = randi() % messages.size()  # Get a random index within the array size
		var que_dijo = messages[rand_index]  # Get the random message from the array

		existing_bunny.emit_signal("ShowDialog", que_dijo)


func dir_contents(_open) ->Array:
	var lista_sprites = []
	var dir = DirAccess.open(_open)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				if file_name.ends_with(".png"):
					lista_sprites.append(_open + file_name)
				else:
					pass
			file_name = dir.get_next()
	else:
		print("ERROR: Poné archivos en la carpeta, la concha de tu hermana.")
	return lista_sprites

func remove_random_node_from_container():
	var container = $playground
	if container.get_child_count() > 0:
		var random_index = randi_range(0, container.get_child_count() - 1)
		var random_node = container.get_child(random_index)
		container.remove_child(random_node)
		random_node.queue_free()  # Optionally free the removed node from memory
	else:
		print("Container is empty, no nodes to remove")
