extends Node2D

var options_menu = preload("res://assets/UI/OptionsMenu.tscn").instance()

var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var soundeffects_bus = AudioServer.get_bus_index("Soundeffects")


func _ready():
	Global.loadScore()
	Settings.loadSettings()
#	for button in $Buttons.get_children():
#		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	$HighscoreLabel.text = "Highscore: " + str(Global.highScore)
	var Config = File.new()
	if Config.file_exists("user://Config"):
		AudioServer.set_bus_volume_db(master_bus, linear2db(Settings.master_volume))
		AudioServer.set_bus_volume_db(music_bus, linear2db(Settings.music_volume))
		AudioServer.set_bus_volume_db(soundeffects_bus, linear2db(Settings.soundeffects_volume))
	else:
		AudioServer.set_bus_volume_db(master_bus, linear2db(.6))
		AudioServer.set_bus_volume_db(music_bus, linear2db(.4))
		AudioServer.set_bus_volume_db(soundeffects_bus, linear2db(.8))
	
	add_child(options_menu)
	$Optionsmenu/Options.visible = false


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_PlayButton_button_down():
	Global.Score = 0
	Global.TotalScore = 0
	Global.MaxWaveEnemies = 4
	Global.CurrentWaveEnemies = 0
	Global.Currentwave = 1
	Global.maxHealth = 500
	Global.EnemyDamage = 300
	Global.Speed = 75
	Global.enemiesKilled = 0 
	Global.unlocked_doors = 0
	var _x = get_tree().change_scene("res://assets/scenes/level2.tscn")


func _on_OptionsButton_button_down():
	$Optionsmenu/Options.visible = true
