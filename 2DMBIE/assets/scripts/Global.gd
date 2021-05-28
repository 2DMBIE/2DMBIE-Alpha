extends Node

signal changeScore(newScore)

var Score = 25000 setget setScore
var ScoreIncrement = 100
var MaxWaveEnemies = 4
var CurrentWaveEnemies = 0
var Currentwave = 1
var maxHealth = 500
var EnemyDamage = 300
var Speed = 75
var enemiesKilled = 0
var unlocked_doors = 0
var game_active = false
var SpecialWaveNumber 
var rng = RandomNumberGenerator.new()

# Debug
var aim = false
var camera = false
var brightness = false

func _process(_delta):
	maxHealth = clamp(maxHealth, 500, 1500)
	EnemyDamage = clamp(EnemyDamage, 300, 600)

	
func _ready():
	rng.randomize()
	SpecialWaveNumber = rng.randi_range(4, 7)

	
func setScore(newScore):
	newScore = max(0, newScore)
	Score = newScore
	emit_signal("changeScore", Score)

func setSpecialWaveNumber():
	if Currentwave >= SpecialWaveNumber:
		rng.randomize()
		SpecialWaveNumber = (rng.randi_range(4, 7) + SpecialWaveNumber)

