extends Node2D

signal zombieSpawned()

var plenemy := preload("res://assets/scenes/zombie.tscn")
var specialEnemy := preload("res://assets/scenes/enemy2.tscn")
var PlayerBody = false
var plEnemy2 := preload("res://assets/scenes/zombieFast.tscn")
var enemyType

func _on_Timer_timeout():
	$Timer.start(5)
	randomizeEnemyType()
	if PlayerBody == true: #checks if the player is in the spawnradius
		if Global.CurrentWaveEnemies < Global.MaxWaveEnemies: #check for the maximum amount of enemies in this round
			if Global.specialWave != true:
				if enemyType >= 1:
					var enemy := plenemy.instance()
					enemy.position = $spawnpoint.get_global_position()
					get_tree().current_scene.add_child(enemy)
					var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
					if enemyAmount >= 10: #maximum amount of enemies on the map at the same time
						enemy.queue_free()
					else:
						Global.CurrentWaveEnemies += 1
				else:
					var enemy2 := plEnemy2.instance()
					enemy2.position = $spawnpoint.get_global_position()
					get_tree().current_scene.add_child(enemy2)
					var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
					if enemyAmount >= 10: #maximum amount of enemies on the map at the same time
						enemy2.queue_free()
					else:
						Global.CurrentWaveEnemies += 1
			else:
				var specialenemy := specialEnemy.instance()
				specialenemy.position = $spawnpoint.get_global_position()
				get_tree().current_scene.add_child(specialenemy)
				var enemyAmount = get_tree().get_nodes_in_group("enemies").size() #checkin the amount of enemies ont the map
				if enemyAmount >= 10: #maximum amount of enemies on the map at the same time
					specialenemy.queue_free()
				else:
					Global.CurrentWaveEnemies += 1
		else: #function for starting timer to the next wave
			var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
			if enemyAmount == 0:
				get_node("../../WaveTimer").start(2) # total wait time is this time + the spawn timer
		
		emit_signal("zombieSpawned")

#collision area to detect the player & spawn enemies
func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false
		
var rng = RandomNumberGenerator.new()

func randomizeEnemyType():
	rng.randomize()
	enemyType = rng.randi_range(0, 10)
	return
