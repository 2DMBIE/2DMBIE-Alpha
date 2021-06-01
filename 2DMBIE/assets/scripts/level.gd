extends Node2D

onready var musicBus := AudioServer.get_bus_index("Music")
onready var musicValue

var is_paused = false
var random_round
var music_playing = false
signal music(action)
var GraphRandomPoint = Vector2.ZERO

var AmmoPouch = preload("res://assets/scenes/ammoPouch.tscn")


func _ready():
	Global.game_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	random_round = 1 #randi()%7+1 # generate random integer between 7 and 1
	
# warning-ignore:return_value_discarded
	gamestate.connect("playersLoaded", self, "_on_playersLoaded")

func _process(_delta):
	musicValue = db2linear(AudioServer.get_bus_volume_db(musicBus))
	
	var ammobagamount = get_tree().get_nodes_in_group("ammo").size()
	if ammobagamount > 1:
		get_tree().get_nodes_in_group("ammo")[0].queue_free()
	var MarkerPos = get_node("Players/"+str(gamestate.player_id)+"/MarkerPos")
	var rotationDegree = GraphRandomPoint.angle_to_point(MarkerPos.global_position)
	MarkerPos.rotation = rotationDegree
		
		
	
	$cursor.position = get_global_mouse_position()
	if Global.Currentwave == random_round and not music_playing:
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
	if is_paused == false:
		if Global.brightness:
			$CanvasModulate.color = Color("#bbbbbb")
		else:
			$CanvasModulate.color = Color("#7f7f7f")
		
	if Input.is_action_just_pressed("pause"):
		if get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible == false:
			if is_paused == false:
				get_node("CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
				get_node("CanvasLayer/CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
				get_tree().paused = true
				get_node("Players/"+str(gamestate.player_id)+"/PauseMenu/Container").visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_paused = true
#				emit_signal("music", "pause")
				AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))
				
			elif is_paused == true and get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible == false:
				unpause_game()
		
	escape_options()

func _on_WaveTimer_timeout(): #stats voor de enemies
	if Global.CurrentWaveEnemies != 0:
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 2
		Global.Currentwave += 1
		Global.maxHealth += 100
		Global.EnemyDamage += 50
		Global.Speed += 4
		Global.enemiesKilled = 0 
	else:
		pass

func unpause_game():
	get_node("CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
	get_node("CanvasLayer/CanvasModulate").set_color(Color(1,1,1,1))
	get_tree().paused = false
	get_node("Players/"+str(gamestate.player_id)+"/PauseMenu/Container").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#	emit_signal("music", "unpause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue*4))
	is_paused = false

func _on_Continue_button_down():
	unpause_game()


func _on_ExitMenu_button_down():
	unpause_game()
	Global.game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")


func _on_ExitOptions_button_down():
	if get_tree().get_current_scene().get_name() == 'Optionsmenu':
		var x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
		if x != OK:
			print("ERROR: ", x)
	else:
		get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible = false
	get_node("Players/"+str(gamestate.player_id)+"/PauseMenu/Container").visible = true
	emit_signal("music", "unpause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))

func escape_options():
	if get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible:
		if Input.is_action_pressed("escape"):
			get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible = false
			get_node("Players/"+str(gamestate.player_id)+"/PauseMenu/Container").visible = true
			emit_signal("music", "unpause")
			AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))


func _on_Options_button_down():
	get_node("Players/"+str(gamestate.player_id)+"/Optionsmenu/Options").visible = true
	get_node("Players/"+str(gamestate.player_id)+"/PauseMenu/Container").visible = false
	emit_signal("music", "pause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue*4))

func _on_Pathfinder_ammopouchSpawn(graphRandomPoint):
	var ammoPouch = AmmoPouch.instance()
	ammoPouch.set_position(graphRandomPoint)
	get_tree().get_current_scene().call_deferred("add_child", ammoPouch)
	GraphRandomPoint = graphRandomPoint

func _on_playersLoaded():
	print(get_node("/root/Lobby/Players/" + str(gamestate.player_id)))


