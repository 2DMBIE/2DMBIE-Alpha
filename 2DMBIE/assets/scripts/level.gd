extends Node2D

var AmmoPouch = preload("res://assets/scenes/ammoPouch.tscn")

var is_paused = false
var is_gameOver = false
var random_round
var music_playing = false
signal music(action)
var GraphRandomPoint

var specialWaveIncrease = 1.15

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
		if get_node("Optionsmenu/Options").visible == false and !is_gameOver:
			if !is_paused:
				pause_game()
				is_paused = true
				get_node("PauseMenu/Container").visible = true
				
			elif is_paused and get_node("Optionsmenu/Options").visible == false:
				unpause_game()
				is_paused = false
				get_node("PauseMenu/Container").visible = false
		
	escape_options()

var waveType = 0
var prevWaveType = 0

func _on_WaveTimer_timeout(): #stats voor de enemies
	if Global.CurrentWaveEnemies != 0:
		if Global.Currentwave == Global.SpecialWaveNumber:
			Global.specialWave = true
			Global.maxHealth *= specialWaveIncrease
			Global.EnemyDamage *= specialWaveIncrease
			Global.Speed *= specialWaveIncrease
			waveType = 1
		else:
			if prevWaveType != waveType:
				Global.specialWave = false
				Global.maxHealth /= specialWaveIncrease
				Global.EnemyDamage /= specialWaveIncrease
				Global.Speed /= specialWaveIncrease
				Global.randomizeSpecialwave()
				waveType = 0
				prevWaveType = waveType
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 2
		Global.Currentwave += 1
		Global.maxHealth += 100
		Global.EnemyDamage += 50
		Global.Speed += 4
		Global.enemiesKilled = 0

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

func rollinghead(bulletPosition, zombie):
	var enemyHead = enemyhead.instance()
	enemyHead.position = bulletPosition
	enemyHead.get_node("Sprite").texture = zombie.get_node("body/torso/neck/head").texture
	call_deferred("add_child", enemyHead)

func _on_zombieSpawned():
	if get_node_or_null("Zombie/body/torso/neck/head") != null:
		for zombie in get_tree().get_nodes_in_group("enemies"):
			if !zombie.is_connected("headroll", self, "rollinghead"):
				zombie.connect("headroll", self, "rollinghead")

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
	Global.randomizeSpecialwave()
	restart_game()


func _on_GameOver_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("GameOver/Container").visible = false
