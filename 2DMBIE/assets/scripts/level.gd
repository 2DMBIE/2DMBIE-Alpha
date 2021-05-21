extends Node2D

var is_paused = false

func _ready():
	Global.game_active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -10)

func _process(_delta):
	$cursor.position = get_global_mouse_position()
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
		if get_node("Optionsmenu/Options").visible == false:
			if is_paused == false:
				get_node("CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
				get_node("CanvasLayer/CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
				get_tree().paused = true
				get_node("PauseMenu/Container").visible = true
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_paused = true
			elif is_paused == true and get_node("Optionsmenu/Options").visible == false:
				unpause_game()
		
	escape_options()

func _on_WaveTimer_timeout(): #stats voor de enemies
	if Global.CurrentWaveEnemies != 0:
		Global.CurrentWaveEnemies = 0
		Global.MaxWaveEnemies += 4
		Global.Currentwave += 1
		Global.maxHealth *= 1.25
		Global.EnemyDamage *= 1.25
		Global.Speed += 4
		Global.enemiesKilled = 0 
	else:
		pass

func unpause_game():
	get_node("CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
	get_node("CanvasLayer/CanvasModulate").set_color(Color(1,1,1,1))
	get_tree().paused = false
	get_node("PauseMenu/Container").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	is_paused = false

func _on_Continue_button_down():
	unpause_game()


func _on_ExitMenu_button_down():
	unpause_game()
	Global.game_active = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")


func _on_ExitOptions_button_down():
	if get_tree().get_current_scene().get_name() == 'Options':
		get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
	else:
		get_node("Optionsmenu/Options").visible = false
	get_node("PauseMenu/Container").visible = true

func escape_options():
	if get_node("Optionsmenu/Options").visible:
		if Input.is_action_pressed("escape"):
			get_node("Optionsmenu/Options").visible = false
			get_node("PauseMenu/Container").visible = true


func _on_Options_button_down():
	get_node("Optionsmenu/Options").visible = true
	get_node("PauseMenu/Container").visible = false
