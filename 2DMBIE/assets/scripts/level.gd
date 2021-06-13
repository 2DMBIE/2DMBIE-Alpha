extends Node2D

onready var musicBus := AudioServer.get_bus_index("Music")
onready var musicValue

var is_paused = false
var music_playing = false
signal music(action)
var GraphRandomPoint = Vector2.ZERO

var AmmoPouch = preload("res://assets/scenes/ammoPouch.tscn")

var MarkerPos = null
var rotationDegree

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "on_player_loaded")

func _process(_delta):
	if MarkerPos != null:
		rotationDegree = GraphRandomPoint.angle_to_point(MarkerPos.global_position)
		MarkerPos.rotation = rotationDegree
	
	$cursor.position = get_global_mouse_position()
	
	var ammobagamount = get_tree().get_nodes_in_group("ammo").size()
	if ammobagamount > 1:
		get_tree().get_nodes_in_group("ammo")[0].queue_free()
	
	if Global.Currentwave == Global.random_round_music and not music_playing:
		emit_signal("music", "play")
		music_playing = true
	if Input.is_action_just_released("game_reset"):
		var _error = get_tree().reload_current_scene()
		#standaard stats voor de enemies
		Global.Score = 0
		Global.MaxWaveEnemies = 4
		Global.CurrentWaveEnemies = 0
		Global.Currentwave = 1
		Global.maxHealth = 500
		Global.EnemyDamage = 300
		Global.Speed = 200
		Global.enemiesKilled = 0 
		Global.unlocked_doors = 0

func _on_WaveTimer_timeout(): #stats voor de enemies
	if Global.CurrentWaveEnemies != 0:
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 2
		Global.Currentwave += 1
		Global.maxHealth += 100
		Global.EnemyDamage += 50
		Global.Speed += 4
		Global.enemiesKilled = 0
		Global.rpc("wavetimer_update", Global.MaxWaveEnemies,Global.Currentwave,Global.maxHealth,Global.EnemyDamage,Global.Speed,Global.enemiesKilled)
	else:
		pass

func _on_Pathfinder_ammopouchSpawn(graphRandomPoint):
#	var ammoPouch = AmmoPouch.instance()
#	ammoPouch.set_position(graphRandomPoint)
#
#	#get_tree().get_current_scene().call_deferred("add_child", ammoPouch)
#	get_tree().root.add_child(ammoPouch)
	#GraphRandomPoint = graphRandomPoint
	print("Spawning ammopouch")
	rpc("set_random_graph_point", graphRandomPoint)
	rpc("spawn_ammopouch", graphRandomPoint)


remotesync func set_random_graph_point(x):
	GraphRandomPoint = x

remotesync func spawn_ammopouch(location):
	if get_tree().root.has_node("ammoPouch"):
		get_tree().root.get_node("ammoPouch").queue_free()
	var ammoPouch = AmmoPouch.instance()
	ammoPouch.set_position(location)
	get_tree().root.add_child(ammoPouch)

func on_player_loaded():
	#var player = get_node("/root/World/Players/" + str(gamestate.player_id))
	#player.rpc("set_color", gamestate.player_color_index)

	MarkerPos = get_node("/root/World/Players/"+ str(gamestate.player_id)+"/MarkerPos")
	MarkerPos.get_node("Marker").visible = true
#	if get_node("Players/"+str(gamestate.player_id)).is_network_master() and not has_node("/root/Lobby"):
#		MarkerPos.get_node("Marker").visible = true
