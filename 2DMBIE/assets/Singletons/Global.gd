extends Node

signal changeScore(newScore)

var Score = 0 setget setScore
var ScoreIncrement = 100
var MaxWaveEnemies = 4
var CurrentWaveEnemies = 0
var Currentwave = 1
var maxHealth = 500
var EnemyDamage = 200
var Speed = 75
var SpeedBaby = 150
var enemiesKilled = 0
var totalEnemiesKilled = 0
var unlocked_doors = 0
var game_active = false
var highScore = 0
var maia = false
var specialWave = false
var TotalScore = 0
var noteCount = 0 #
var neededNotes = 20 # max 20, anders pijn in geen notes meer

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
	
var SpecialWaveNumber = 0 
var rng = RandomNumberGenerator.new()

func setSpecialWaveNumber():
	if Currentwave >= SpecialWaveNumber:
		SpecialWaveNumber = randomizeSpecialwave() + SpecialWaveNumber

func _ready():
	randomizeSpecialwave()

func randomizeSpecialwave():
	rng.randomize()
	SpecialWaveNumber = rng.randi_range(3, 6)
	return SpecialWaveNumber
	
	

