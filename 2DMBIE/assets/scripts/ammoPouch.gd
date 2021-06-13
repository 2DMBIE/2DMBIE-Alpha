extends Area2D

func _on_ammoPouch_body_entered(body):
	if body.is_in_group("player"):
		queue_free()

#mastersync func del_object():
#	queue_free()
