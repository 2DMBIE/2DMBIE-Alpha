extends Node2D

var plenemy := preload("res://assets/scenes/zombie.tscn")
var PlayerBody = false

func _on_Timer_timeout():
	$Timer.start(5)
	print(PlayerBody)
	if PlayerBody == true:
		var enemy := plenemy.instance()
		enemy.position = $spawnpoint.get_global_position()
		get_tree().current_scene.add_child(enemy)
		var enemyAmount = get_tree().get_nodes_in_group("enemies").size()
		print(enemyAmount)
		if enemyAmount > 15:
			enemy.queue_free()

func _on_PlayerDetectionRadius_body_entered(body):
	if body.is_in_group("player"):
		PlayerBody = true

func _on_PlayerDetectionRadius_body_exited(body):
	if body.is_in_group("player"):
		PlayerBody = false
