extends TextureProgress

func _ready():
	set_network_master(1)

func _physics_process(_delta):
	if is_network_master():
		max_value = Global.MaxWaveEnemies
		value = Global.MaxWaveEnemies - Global.enemiesKilled
		rpc("set_wavemeter", Global.MaxWaveEnemies, (Global.MaxWaveEnemies-Global.enemiesKilled))

remote func set_wavemeter(max_value_remote, value_remote):
	max_value = max_value_remote
	value = value_remote
