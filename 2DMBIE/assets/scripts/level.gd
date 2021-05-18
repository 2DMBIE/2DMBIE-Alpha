extends Node2D

var is_paused = false

func _ready():
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
		
	if Input.is_action_just_pressed("pause"):
		print("pause button!")
		if is_paused == false:
			get_node("CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
			get_node("CanvasLayer/CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
			is_paused = true
			get_tree().paused = true
			print('game paused')
		elif is_paused == true:
			get_node("CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
			get_node("CanvasLayer/CanvasModulate").set_color(Color(1,1,1,1))
			is_paused = false
			get_tree().paused = false
			print('game unpaused')

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
