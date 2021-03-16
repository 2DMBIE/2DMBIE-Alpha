extends Node2D

var plenemy := preload("res://assets/scenes/zombie.tscn")

func enemy_spawn():
		var enemy := plenemy.instance()
		enemy.position = $spawnpoint.get_global_position()
		get_tree().get_root().add_child(enemy)

func _on_Timer_timeout():
	enemy_spawn()
	$Timer.start(5)
