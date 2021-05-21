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

# Debug
var aim = false
var camera = true
var brightness = false

func _process(_delta):
	maxHealth = clamp(maxHealth, 500, 1500)
	EnemyDamage = clamp(EnemyDamage, 300, 600)
	Speed = clamp(Speed, 200, 400)

func setScore(newScore):
	newScore = max(0, newScore)
	Score = newScore
	emit_signal("changeScore", Score)
