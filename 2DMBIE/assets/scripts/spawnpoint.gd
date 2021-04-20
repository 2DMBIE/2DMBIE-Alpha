extends Node2D

var plenemy := preload("res://assets/scenes/zombie.tscn")
var PlayerBody = false


func _on_Timer_timeout():
	if PlayerBody == true:
		if Global.CurrentWaveEnemies < Global.MaxWaveEnemies:
			$Timer.start(5)
			var enemy := plenemy.instance()
			enemy.position = $spawnpoint.get_global_position()
			get_tree().current_scene.add_child(enemy)
			var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
			Global.CurrentWaveEnemies += 1
			print(Global.CurrentWaveEnemies)
			if enemyAmount > 20:
				enemy.queue_free()
		else:
			print("next wave")
			Global.Currentwave += 1 
			$WaveTimer.start(5)

func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false

func _on_WaveTimer_timeout():
	print("new enemies")
	$Timer.start(5)
	Global.CurrentWaveEnemies = 0
	Global.Currentwave += 1 
	Global.MaxWaveEnemies += 4
