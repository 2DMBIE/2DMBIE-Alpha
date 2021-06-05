extends Node

# Default game port
const DEFAULT_PORT = 25565

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "Unnamed"
var host_name
var last_player_name = ""

# Names for remote players in id:name format
var players = {}

# Signals to let lobby GUI know what's going ona
signal on_player_join(name)
signal on_player_leave(id, name)
signal lobby_created(id, name)
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree
func _player_connected(_id):
	pass
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.

# Callback from SceneTree
func _player_disconnected(id):
	if get_tree().is_network_server():
		if has_node("/root/world"): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	rpc("add_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	if has_node("/root/Lobby"): # Game is in progress.
		get_node("/root/Lobby").queue_free()
		get_tree().get_root().get_node("LobbyUI").hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

remote func register_player(id, new_player_name):
	if get_tree().is_network_server():
		for p_id in players:
			rpc_id(id, "show_join_msg", new_player_name)
		
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new dude
		rpc_id(id, "add_player", 1, player_name)
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(id, "add_player", p_id, players[p_id])
			
			rpc_id(p_id, "register_player", id, new_player_name) # Send new dude to player
			rpc_id(p_id, "add_player", id, new_player_name) # Send new dude to player

	players[id] = new_player_name
	add_player(id, new_player_name)
	#show_join_msg(new_player_name)
	print("Player: " + new_player_name + " joined!! ")

remote func unregister_player(id):
	emit_signal("on_player_leave", id, players[id])
	players.erase(id)
	if has_node("/root/Lobby/Players/" + str(id)):
		get_node("/root/Lobby/Players/" + str(id)).queue_free()

remote func add_player(id, name):
	#var id = get_tree().get_rpc_sender_id()
	if has_node("/root/Lobby") and not has_node("/root/Lobby/Players/" + str(id)):
		var world = get_node("/root/Lobby")
		var player_scene = load("res://assets/scenes/player.tscn")
		var player = player_scene.instance()
		player.set_name(str(id))
		player.set_player_name(name)
		var spawn_pos = world.get_node("SpawnPoints/0").position
		player.position=spawn_pos
		player.set_network_master(id)
		world.get_node("Players").add_child(player)

remote func show_join_msg(name):
	emit_signal("on_player_join", name)
	
remote func pre_start_game(spawn_points):
	# Change scene
	var main = load("res://scenes/main.tscn").instance()
	get_tree().get_root().add_child(main)

	get_tree().get_root().get_node("lobby").hide()

	var player_scene = load("res://scenes/player/player.tscn")

	for p_id in spawn_points:
		var spawn_pos = main.get_node("spawn_points/" + str(spawn_points[p_id])).global_transform.origin
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.set_network_master(p_id) #set unique id as master
		player.global_transform.origin = spawn_pos
		
		main.get_node("players").add_child(player)

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

func host_game(new_player_name):
	player_name = new_player_name
	host_name = player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_name = new_player_name
	last_player_name = player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)

func end_game():
	if has_node("/root/world"): # Game is in progress
		# End it
		get_node("/root/world").queue_free()

	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking

# Loads the player (you) and the map.
func load_lobby():
	var world = load("res://assets/scenes/LobbyWorld.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("LobbyUI").hide()
	
	var player_scene = load("res://assets/scenes/player.tscn")
	var player = player_scene.instance()
	player.set_name(str(get_tree().get_network_unique_id()))
	player.set_player_name(player_name)
	var spawn_pos = world.get_node("SpawnPoints/0").position
	player.position=spawn_pos
	player.set_network_master(get_tree().get_network_unique_id())
	world.get_node("Players").add_child(player)
	
	if get_tree().get_network_unique_id() == 1:
		emit_signal("lobby_created", host_name)
	if !last_player_name == "":
		emit_signal("on_player_join", last_player_name)

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
