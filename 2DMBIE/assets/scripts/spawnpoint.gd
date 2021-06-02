extends Node2D

signal zombieSpawned()

var plenemy := preload("res://assets/scenes/zombie.tscn")
var specialEnemy := preload("res://assets/scenes/enemy2.tscn")
var PlayerBody = false
var specialWave = false

func _on_Timer_timeout():
	$Timer.start(5)
	if PlayerBody == true: #checks if the player is in the spawnradius
		if Global.CurrentWaveEnemies < Global.MaxWaveEnemies: #check for the maximum amount of enemies in this round
			if Global.Currentwave != Global.SpecialWaveNumber:	
				var enemy := plenemy.instance()
				enemy.position = $spawnpoint.get_global_position()
				get_tree().current_scene.add_child(enemy)
				var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
				Global.CurrentWaveEnemies += 1
				if enemyAmount > 10: #maximum amount of enemies on the map at the same time
					enemy.queue_free()
			else: 
				specialWave = true
				Global.EnemyDamage += 50
				Global.maxHealth += 300
				Global.Speed += 25
				var specialenemy := specialEnemy.instance()
				specialenemy.position = $spawnpoint.get_global_position()
				get_tree().current_scene.add_child(specialenemy)
				var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
				Global.CurrentWaveEnemies += 1
				if enemyAmount > 10: #maximum amount of enemies on the map at the same time
					specialenemy.queue_free()

		else: #function for starting timer to the next wave
			var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
			if enemyAmount == 0:
				get_node("../../WaveTimer").start(2) # total wait time is this time + the spawn timer
	
			if specialWave == true:
				Global.setSpecialWaveNumber()
				Global.EnemyDamage -= 50
				Global.maxHealth -= 300
				Global.Speed -= 25
				specialWave = false
		
		emit_signal("zombieSpawned")

#collision area to detect the player & spawn enemies
func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false
		


