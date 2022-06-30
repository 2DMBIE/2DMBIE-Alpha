extends Node2D

var AmmoPouch = preload("res://world/interactable_objects/ammo_pouch/ammo_pouch.tscn")

var is_paused = false
var is_gameOver = false
var random_round
var music_playing = false
signal music(action)
var GraphRandomPoint
var notePause = false
var music_box_bus = AudioServer.get_bus_index("MusicBox")
var music_box_game = AudioServer.get_bus_index("MusicGame")
var music_box_playing = false
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
	SpawnNote()
	emit_signal("music", "play")

func _process(_delta):
	var ammobagamount = get_tree().get_nodes_in_group("ammo").size()
	if ammobagamount > 1:
		get_tree().get_nodes_in_group("ammo")[0].queue_free()
	if get_node_or_null("Player") != null and GraphRandomPoint != null:
		var MarkerPos = $Player/MarkerPos.global_position
		var rotationDegree = (GraphRandomPoint.angle_to_point(MarkerPos))
		$Player/MarkerPos.rotation = (rotationDegree)
	
	if Global.boxMusicNode != null:
		if Global.boxMusicNode.playing == true:
			emit_signal("music", "pause")
			music_box_playing = true
		else:
			emit_signal("music", "unpause")
			music_box_playing = false
			Global.boxMusicNode = null
	


	$cursor.position = get_global_mouse_position()
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
			notePause = false
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
			Global.setSpecialWaveNumber()
			waveType = 1
#			if not music_playing: #random_round
#				emit_signal("music", "play")
#				music_playing = true
		else:
			if prevWaveType != waveType:
				enemyWaveStats()
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 2
		Global.Currentwave += 1
		Global.maxHealth += 100
		Global.EnemyDamage *= 1.05
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
	AudioServer.set_bus_mute(0, true)

func unpause_game():
	get_tree().paused = false
	get_node("CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
	get_node("CanvasLayer/CanvasModulate").set_color(Color(1,1,1,1))
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$cursor.visible = true
	if music_box_playing == false:
		emit_signal("music", "unpause")
	AudioServer.set_bus_mute(0, false)

func restart_game():
	var _error = get_tree().reload_current_scene()
	resetGameValues()

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
	resetGameValues()
	
	Global.game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _x = get_tree().change_scene("res://gui/main_menu_old/main_menu_old.gd")


func _on_ExitOptions_button_down():
	$Optionsmenu/Options.saveSettings()
	if get_tree().get_current_scene().get_name() == 'Optionsmenu':
		var x = get_tree().change_scene("res://gui/main_menu_old/main_menu_old.tscn")
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


func _on_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("PauseMenu/Container").visible = false

var enemyhead = preload("res://zombie/scenes/rolling_zombie_head.tscn")

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
	enemyWaveStats()
	

func enemyWaveStats():
	Global.specialWave = false
	Global.maxHealth /= specialWaveIncrease
	Global.EnemyDamage /= specialWaveIncrease
	Global.Speed /= specialWaveIncrease
	waveType = 0

func resetGameValues():
	#standaard stats voor de enemies
	Global.Score = 0
	Global.TotalScore = 0
	Global.MaxWaveEnemies = 4
	Global.CurrentWaveEnemies = 0
	Global.Currentwave = 1
	Global.maxHealth = 500
	Global.EnemyDamage = 200
	Global.Speed = 75
	Global.enemiesKilled = 0 
	Global.unlocked_doors = 0
	Global.noteCount = 0
	Global.debug = false

func _on_PlayAgainButton_button_down():
	get_tree().paused = false
	restart_game()
	emit_signal("music", "unpause")
	AudioServer.set_bus_mute(0, false)
	Global.randomizeSpecialwave()


func _on_GameOver_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("GameOver/Container").visible = false

var allowNotes = true

func SpawnNote():
	var noteScene = preload("res://world/interactable_objects/sticky_note/sticky_note.tscn")
	var Notescene = noteScene.instance()
	var notePosition
	if allowNotes:
		if get_tree().get_nodes_in_group("spawnpoints").size() != 0:
			if Global.noteCount >= Global.neededNotes:
				notePosition = get_node("lastNote").get_global_position()
				allowNotes = false
			else: 
				var spawnpointAmount = get_tree().get_nodes_in_group("spawnpoints").size()
				var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
				randomize()
				var randomspawn = randi() % spawnpointAmount
				notePosition = spawnpoints[randomspawn].get_global_position()
				
			Notescene.set_position(notePosition)
			add_child(Notescene)
		# warning-ignore:return_value_discarded
			$StickeyNote.connect("readNote", $CanvasLayer/NotePopup, "onNoteRead") 
		# warning-ignore:return_value_discarded
			$StickeyNote.connect("closeNote", $CanvasLayer/NotePopup, "CloseNote")
	
func _on_NotePopup_pauseGame():
	get_tree().paused = true
	notePause = true

