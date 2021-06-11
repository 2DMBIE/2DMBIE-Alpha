extends Node

# Default game port
const DEFAULT_PORT = 25565

# Max number of players: 4 including host!
const MAX_PEERS = 3

# Name for my player
var player_name = "Unnamed"
var host_name
var player_id
var last_player_name = ""

# To send in-game join message
var player_join_cache = []

# Names for remote players in id:name format
var players = {}

# Signals to let lobby GUI know what's going ona
signal on_player_join(id, name)
signal on_player_leave(id, name)
signal lobby_created(name)
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)
signal on_local_player_loaded() #playersLoaded
signal player_added(id, name)

# Callback from SceneTree
func _player_connected(_id):
	pass
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.

# Callback from SceneTree
func _player_disconnected(id):
	if get_tree().is_network_server():
		if get_tree().root.has_node("/root/World"): # Game is in progress
			var msg = "Player " + players[id] + " disconnected"
			for p_id in players:
				rpc_id(p_id, "end_game_error", msg)
			end_game_error(msg)
		else:
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

remote func end_game_error(msg):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("game_error", msg)
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	rpc("add_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")
	print("connect")

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	if has_node("/root/Lobby"): # Game is in progress.
		get_node("/root/Lobby").queue_free()
	elif has_node("/root/World"): # Game is in progress.
		get_node("/root/World").queue_free()
	get_tree().get_root().get_node("LobbyUI").hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("game_error", "Server disconnected")
	end_game()
	print("server")

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")
	player_join_cache = []
	players = {}
	players_ready = []

# Lobby management functions
remote func register_player(id, new_player_name):
	if get_tree().is_network_server():
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
	if get_tree().is_network_server():
		if not player_join_cache.has(id):
			for id in players: 
				rpc_id(id, "show_join_msg", id, new_player_name)
			show_join_msg(id, new_player_name)
			player_join_cache.append(id)

remote func unregister_player(id):
	if not players.has(id):
		return
	emit_signal("on_player_leave", players[id])
	players.erase(id)
	player_join_cache.erase(id)
	if get_tree().get_root().has_node("/root/Lobby/Players/" + str(id)):
		get_tree().get_root().get_node("/root/Lobby/Players/" + str(id)).queue_free()
	elif get_tree().get_root().has_node("/root/World/Players/" + str(id)):
		get_tree().get_root().get_node("/root/World/Players/" + str(id)).queue_free()

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
		emit_signal("player_added", id, name)

remote func show_join_msg(id, name):
	emit_signal("on_player_join", id, name)
	
remote func pre_start_game(spawn_points):
	# Change scene
	var main = load("res://assets/scenes/World.tscn").instance()
	get_tree().get_root().add_child(main)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://assets/scenes/player.tscn")

	for p_id in spawn_points:
		var spawn_pos = main.get_node("p_Spawnpoints/" + str(spawn_points[p_id])).global_transform.origin
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name
		player.set_network_master(p_id) #set unique id as master
		player.position = spawn_pos
		main.get_node("Players").add_child(player)

	if not get_tree().is_network_server():
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().get_root().get_node("Lobby").queue_free()
	get_tree().set_pause(false) # Unpause and unleash the game!
	emit_signal("on_local_player_loaded")

var players_ready = []

remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()

var host

func host_game(new_player_name):
	player_name = new_player_name
	host_name = player_name
	host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)

func join_game(ip, new_player_name):
	player_name = new_player_name
	last_player_name = player_name
	host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)

func get_player_list():
	return players.values()

func get_player_name():
	return player_name

func begin_game():
	assert(get_tree().is_network_server())
	#host.refuse_new_connections = true
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
	if get_tree().get_root().has_node("/root/World"): # Game is in progress
		get_tree().get_root().get_node("/root/World").queue_free() # End it
	elif get_tree().get_root().has_node("/root/Lobby"):
		get_tree().get_root().get_node("/root/Lobby").queue_free()
	emit_signal("game_ended")
	players.clear()
	player_join_cache.clear()
	players_ready.clear()
	get_tree().network_peer = null
	#get_tree().set_network_peer(null) # End networking

# Loads the player (you) and the map.
func load_lobby():
	var world = load("res://assets/scenes/LobbyWorld.tscn").instance()
	get_tree().get_root().add_child(world)
	get_tree().get_root().get_node("LobbyUI").hide()
	
	var player_scene = load("res://assets/scenes/player.tscn")
	var player = player_scene.instance()
	player.set_name(str(get_tree().get_network_unique_id()))
	player.set_player_name(player_name)
	var spawnpoint_number = randi()%7 # generate random integer between 6 and 0
	var spawn_pos = world.get_node("SpawnPoints/" + str(spawnpoint_number)).position
	player.position=spawn_pos
	player.set_network_master(get_tree().get_network_unique_id())
	world.get_node("Players").add_child(player)
	player_id = get_tree().get_network_unique_id()
	
	if get_tree().get_network_unique_id() == 1:
		emit_signal("lobby_created", host_name)
	emit_signal("on_local_player_loaded")
	emit_signal("player_added", player_id, player_name)

func _ready():
	randomize() # enabled for spawning at random locations
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
