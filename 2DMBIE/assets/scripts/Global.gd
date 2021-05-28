extends Node

signal changeScore(newScore)

var Score = 25000 setget setScore
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
var prevScore = 0
var highScore = 0

# Debug
var aim = false
var camera = false
var brightness = false

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
	prevScore = int(saveScoreFile.get_line())
	highScore = int(saveScoreFile.get_line())
	saveScoreFile.close()

func setHighscore():
	if Score > prevScore:
		highScore = Score

func saveScore():
	prevScore = Score
	var saveScoreFile = File.new()
	saveScoreFile.open("user://highscore.save", File.WRITE)
	saveScoreFile.store_line(str(prevScore))
	saveScoreFile.store_line(str(highScore))
	saveScoreFile.close()
	
