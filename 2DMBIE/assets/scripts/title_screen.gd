extends Node2D
var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var soundeffects_bus = AudioServer.get_bus_index("Soundeffects")


func _ready():
	Global.loadScore()
	Settings.loadSettings()
	for button in $Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	$HighscoreLabel.text = "Highscore: " + str(Global.highScore)
	AudioServer.set_bus_volume_db(master_bus, linear2db(Settings.master_volume))
	AudioServer.set_bus_volume_db(music_bus, linear2db(Settings.music_volume))
	AudioServer.set_bus_volume_db(soundeffects_bus, linear2db(Settings.soundeffects_volume))
	
func _on_Button_pressed(scene_to_load):
	if scene_to_load == "res://assets/scenes/level2.tscn":
		Global.Score = 0
		Global.MaxWaveEnemies = 4
		Global.CurrentWaveEnemies = 0
		Global.Currentwave = 1
		Global.maxHealth = 500
		Global.EnemyDamage = 300
		Global.Speed = 200
		Global.enemiesKilled = 0 
		Global.unlocked_doors = 0
	var _x = get_tree().change_scene(scene_to_load)

func _on_ExitButton_pressed():
	get_tree().quit()
