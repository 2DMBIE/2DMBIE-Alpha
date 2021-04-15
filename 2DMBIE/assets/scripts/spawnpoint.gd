extends Node2D

var plenemy := preload("res://assets/scenes/zombie.tscn")

func _on_Timer_timeout():
	var enemy := plenemy.instance()
	enemy.position = $spawnpoint.get_global_position()
	get_tree().current_scene.add_child(enemy)
	$Timer.start(5)
	var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
	print(enemyAmount)
	if enemyAmount > 50:
		enemy.queue_free()

