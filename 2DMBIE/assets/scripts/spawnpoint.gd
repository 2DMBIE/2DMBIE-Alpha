extends Node2D

const name_generator = preload("res://assets/scripts/name-generator.gd")
var plenemy := preload("res://assets/scenes/zombie.tscn")
var PlayerBody = false

func _ready():
	set_network_master(1)

func _on_Timer_timeout():
	if is_network_master():
		$Timer.start(5)
		if PlayerBody == true: #checks if the player is in the spawnradius
			if Global.CurrentWaveEnemies < Global.MaxWaveEnemies: #check for the maximum amount of enemies in this round
				var name = name_generator.generate()
				var enemy_health = Global.maxHealth
				var enemy_damage = Global.EnemyDamage
				rpc("spawn_enemy", $spawnpoint.get_global_position(), name, enemy_health, enemy_damage)
				
				var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
				Global.CurrentWaveEnemies += 1
#				if enemyAmount > 10: #maximum amount of enemies on the map at the same time
#					rpc("kill_enemy", name)
			else: #function for starting timer to the next wave
				var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
				if enemyAmount == 0:
					get_tree().root.get_node("/root/World/WaveTimer").start(2) # total wait time is this time + the spawn timer

#collision area to detect the player & spawn enemies
func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false

remotesync func spawn_enemy(spawnpoint, name, health, damage):
	var enemy := plenemy.instance()
	enemy.name = name
	enemy.position = spawnpoint
	enemy.maxHealth = health
	enemy.enemyDamage = damage
	get_tree().root.get_node("/root/World/Enemies").add_child(enemy)

remotesync func kill_enemy(name):
	var enemy = get_tree().root.get_node_or_null("root/World/Enemies/" + name)
	if enemy != null:
		print("killing target")
		enemy.rpc("kill")
		#enemy.queue_free()
	#get_tree().root.get_node("/root/World").get_node(name).queue_free()

