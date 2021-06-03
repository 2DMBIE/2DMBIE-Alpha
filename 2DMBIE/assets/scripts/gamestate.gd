extends Node

signal playersLoaded()

# Default game server port. Can be any number between 1024 and 49151.
# Not on the list of registered or common ports as of November 2020:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
const DEFAULT_PORT = 25565

# Max number of players.
const MAX_PEERS = 4

var peer = null

# Name for my player.
var player_name = "Player 1"

# Names for remote players in id:name format.
var players = {}
var players_ready = []

var player_id = 1
# Signals to let lobby GUI know what's going on.
signal on_player_join(id, name)
signal on_player_leave(id, name)
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	# Remove world if connected
	if has_node("/root/Lobby"): # Game is in progress.
		get_node("/root/Lobby").queue_free()
		get_tree().get_root().get_node("LobbyUI").hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	players[id] = new_player_name
	emit_signal("player_list_changed")
	emit_signal("on_player_join", id, new_player_name)

func unregister_player(id):
	var _name = players[id]
	if has_node("/root/Lobby"):
		get_node("/root/Lobby/Players/" + str(id)).queue_free()
	emit_signal("on_player_leave", id, _name)
	players.erase(id)
	emit_signal("player_list_changed")
	if has_node("/root/World"): ## game started
		pass
	elif has_node("/root/Lobby"):
		pass


remote func pre_start_game(spawn_points):
	# Refuse new connections
	#peer.refuse_new_connections = true
	# Change scene.
	var world = load("res://assets/scenes/World.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("LobbyUI").hide()

	var player_scene = load("res://assets/scenes/player.tscn")

	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])

		world.get_node("Players").add_child(player)

	# Set up score.
	world.get_node("Score").add_player(get_tree().get_network_unique_id(), player_name)
	for pn in players:
		world.get_node("Score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func pre_start_lobby(spawn_points): 
	# Change scene.
	var world = load("res://assets/scenes/LobbyWorld.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("LobbyUI").hide()

	var player_scene = load("res://assets/scenes/player.tscn")
	
	
	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
			
			player_id = p_id
			
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])
	
		world.get_node("Players").add_child(player)
	
	emit_signal("playersLoaded")
	
	# Set up score.
	#world.get_node("Score").add_player(get_tree().get_network_unique_id(), player_name)
	#for pn in players:
	#	world.get_node("Score").add_player(pn, players[pn])

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


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
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	#start_lobby()


func join_game(ip, new_player_name):
	player_name = new_player_name
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(peer)

func get_player_list():
	return players.values()


func get_player_name():
	return player_name

func start_lobby():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0. {1:0} ID: 1, Spawnpoint 
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx # first iteration would be {2131244:1} then {321321:2} etc.
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.

	# its all empty so this loop wont run except for line 227.
	for p in players:
		rpc_id(p, "pre_start_lobby", spawn_points)

	pre_start_lobby(spawn_points)
	
func load_lobby():
	var world = load("res://assets/scenes/LobbyWorld.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("LobbyUI").hide()

	var player_scene = load("res://assets/scenes/player.tscn")
	# get other players location?
	return
	var spawn_points = {1:0}
	for p_id in spawn_points:
		var spawn_pos = world.get_node("SpawnPoints/" + str(spawn_points[p_id])).position
		var player = player_scene.instance()

		player.set_name(str(p_id)) # Use unique ID as node name.
		player.position=spawn_pos
		player.set_network_master(p_id) #set unique id as master.

		if p_id == get_tree().get_network_unique_id():
			# If node for this peer id, set name.
			player.set_player_name(player_name)
			
			player_id = p_id
			
		else:
			# Otherwise set name from peer.
			player.set_player_name(players[p_id])
	
		world.get_node("Players").add_child(player)

func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing.
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0.
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points.
	
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()

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
