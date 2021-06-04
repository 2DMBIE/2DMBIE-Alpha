extends Node2D

var is_paused = false
var is_gameOver = false
var random_round
var music_playing = false
signal music(action)
var GraphRandomPoint
var notePause = false

var AmmoPouch = preload("res://assets/scenes/ammoPouch.tscn")

func _ready():
	get_tree().paused = false
	Global.game_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	random_round = randi()%2+3 # generate random integer between 5 and 3
	Global.loadScore()
	var _x = $Player.connect("on_death", self, "on_death")
	var _xx = $Optionsmenu/Options.connect("sendHealth", $Player, "_on_maxHealth_toggled")
	for spawnpoint in get_tree().get_nodes_in_group("spawnpoints"):
		spawnpoint.connect("zombieSpawned", self, "_on_zombieSpawned")
	_on_zombieSpawned()
	SpawnNote()


func _process(_delta):
	var ammobagamount = get_tree().get_nodes_in_group("ammo").size()
	if ammobagamount > 1:
		get_tree().get_nodes_in_group("ammo")[0].queue_free()
	if get_node_or_null("Player") != null:
		var MarkerPos = $Player/MarkerPos.global_position
		var rotationDegree = (GraphRandomPoint.angle_to_point(MarkerPos))
		$Player/MarkerPos.rotation = (rotationDegree)


	$cursor.position = get_global_mouse_position()
	if Global.Currentwave == random_round and not music_playing:
		emit_signal("music", "play")
		music_playing = true
	if Input.is_action_just_released("game_reset") and Settings.debugMode:
		restart_game()
	if !is_paused and !is_gameOver:
		if Settings.brightness:
			$CanvasModulate.color = Color("#bbbbbb")
		else:
			$CanvasModulate.color = Color("#7f7f7f")

	if Input.is_action_just_pressed("pause"):
		if notePause == false:
			if get_node("Optionsmenu/Options").visible == false and !is_gameOver:
				if !is_paused:
					pause_game()
					is_paused = true
					get_node("PauseMenu/Container").visible = true
					
				elif is_paused and get_node("Optionsmenu/Options").visible == false:
					unpause_game()
					is_paused = false
					get_node("PauseMenu/Container").visible = false
		else:
			get_tree().paused = false
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
		
		var noteAmount = get_tree().get_nodes_in_group("notes").size()
		if noteAmount == 1:
			pass
		else:
			SpawnNote()
	else:
		pass

func pause_game():
		get_tree().paused = true
		get_node("CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
		get_node("CanvasLayer/CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		$cursor.visible = false
		emit_signal("music", "pause")
	#	AudioServer.set_bus_mute(0, true)

func unpause_game():
	get_tree().paused = false
	get_node("CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
	get_node("CanvasLayer/CanvasModulate").set_color(Color(1,1,1,1))
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$cursor.visible = true
	emit_signal("music", "unpause")
	AudioServer.set_bus_mute(0, false)

func restart_game():
	var _error = get_tree().reload_current_scene()
	#standaard stats voor de enemies
	Global.Score = 0
	Global.MaxWaveEnemies = 4
	Global.CurrentWaveEnemies = 0
	Global.Currentwave = 1
	Global.maxHealth = 500
	Global.EnemyDamage = 300
	Global.Speed = 75
	Global.enemiesKilled = 0 
	Global.unlocked_doors = 0

func _on_Continue_button_down():
	unpause_game()
	is_paused = false
	get_node("PauseMenu/Container").visible = false


func _on_ExitMenu_button_down():
	unpause_game()
	is_paused = false
	is_gameOver = false
	get_node("PauseMenu/Container").visible = false
	get_node("GameOver/Container").visible = false
	
	Global.game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")


func _on_ExitOptions_button_down():
	$Optionsmenu/Options.saveSettings()
	if get_tree().get_current_scene().get_name() == 'Optionsmenu':
		var x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
		if x != OK:
			print("ERROR: ", x)
	else:
		get_node("Optionsmenu/Options").visible = false
	
	if is_paused:
		get_node("PauseMenu/Container").visible = true
	elif is_gameOver:
		get_node("GameOver/Container").visible = true
		

func escape_options():
	$Optionsmenu/Options.saveSettings()
	if get_node("Optionsmenu/Options").visible:
		if Input.is_action_pressed("escape"):
			if is_paused:
				get_node("PauseMenu/Container").visible = true
			elif is_gameOver:
				get_node("GameOver/Container").visible = true
			get_node("Optionsmenu/Options").visible = false


func _on_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("PauseMenu/Container").visible = false

var enemyhead = preload("res://assets/scenes/enemyhead.tscn")

func rollinghead(bulletPosition):
	var enemyHead = enemyhead.instance()
	enemyHead.position = bulletPosition
	call_deferred("add_child", enemyHead)

func _on_zombieSpawned():
	if get_node_or_null("Zombie/body/torso/neck/head") != null:
		for zombie in get_tree().get_nodes_in_group("enemies"):
			if !zombie.is_connected("headroll", self, "rollinghead"):
				var _x = zombie.connect("headroll", self, "rollinghead")

func _on_Pathfinder_ammopouchSpawn(graphRandomPoint):
	var ammoPouch = AmmoPouch.instance()
	ammoPouch.set_position(graphRandomPoint)
	get_tree().get_current_scene().call_deferred("add_child", ammoPouch)
	GraphRandomPoint = graphRandomPoint
	

func on_death():
	pause_game()
	is_gameOver = true
	get_node("GameOver/Container").visible = true


func _on_PlayAgainButton_button_down():
	emit_signal("music", "unpause")
	AudioServer.set_bus_mute(0, false)
	get_tree().paused = false
	restart_game()


func _on_GameOver_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("GameOver/Container").visible = false


func SpawnNote():
	var noteScene = preload("res://assets/scenes/stickyNote.tscn")
	var Notescene = noteScene.instance()
	var spawnpointAmount = get_tree().get_nodes_in_group("spawnpoints").size()
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	randomize()
	var randomspawn = randi() % spawnpointAmount
	var notePosition = spawnpoints[randomspawn].get_global_position()
	Notescene.set_position(notePosition)
	add_child(Notescene)
	$StickeyNote.connect("readNote", $CanvasLayer/NotePopup, "onNoteRead") 
	$StickeyNote.connect("closeNote", $CanvasLayer/NotePopup, "CloseNote")	
	
func _on_NotePopup_pauseGame():
	get_tree().paused = true
	notePause = true

