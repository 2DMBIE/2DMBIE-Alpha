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
var paused = false
var online = true
# Debug
var aim = false
var camera = false
var brightness = false

func _process(_delta):
	maxHealth = clamp(maxHealth, 500, 1500)
	EnemyDamage = clamp(EnemyDamage, 300, 600)
	Speed = clamp(Speed, 200, 400)

func setScore(newScore):
	newScore = max(0, newScore)
	Score = newScore
	emit_signal("changeScore", Score)

remote func add_to_global(variable, value):
	if variable == "MaxWaveEnemies":
		MaxWaveEnemies += value
	elif variable == "CurrentWaveEnemies":
		CurrentWaveEnemies += value
	elif variable == "enemiesKilled":
		enemiesKilled += value

remote func wavetimer_update(remote_MaxWaveEnemies, remote_Currentwave, remote_maxHealth, remote_EnemyDamage, remote_Speed, remote_enemiesKilled):
	Global.MaxWaveEnemies = remote_MaxWaveEnemies
	Global.Currentwave = remote_Currentwave
	Global.maxHealth = remote_maxHealth
	Global.EnemyDamage = remote_EnemyDamage
	Global.Speed = remote_Speed
	Global.enemiesKilled = remote_enemiesKilled
