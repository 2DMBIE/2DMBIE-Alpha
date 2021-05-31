extends Node

signal changeScore(newScore)

var Score = 0 setget setScore
var ScoreIncrement = 100
var MaxWaveEnemies = 4
var CurrentWaveEnemies = 0
var Currentwave = 1
var maxHealth = 500
var EnemyDamage = 300
var Speed = 200
var enemiesKilled = 0
var unlocked_doors = 0
var game_active = false
var highScore = 0
var debugMode = false
var maia = false

func _process(_delta):
	pass

func setScore(newScore):
	newScore = max(0, newScore)
	Score = newScore
	emit_signal("changeScore", Score)

func loadScore():
	var saveScoreFile = File.new()
	if not saveScoreFile.file_exists("user://highscore.save"):
		return
	saveScoreFile.open("user://highscore.save", File.READ)
	highScore = int(saveScoreFile.get_line())
	saveScoreFile.close()

func setHighscore():
	if Score > highScore:
		highScore = Score

func saveScore():
	var saveScoreFile = File.new()
	saveScoreFile.open("user://highscore.save", File.WRITE)
	saveScoreFile.store_line(str(highScore))
	saveScoreFile.close()
	
