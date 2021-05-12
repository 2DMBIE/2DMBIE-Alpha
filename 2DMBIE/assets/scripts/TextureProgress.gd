extends TextureProgress

func _physics_process(_delta):
	max_value = Global.MaxWaveEnemies
	value = Global.MaxWaveEnemies - Global.enemiesKilled

