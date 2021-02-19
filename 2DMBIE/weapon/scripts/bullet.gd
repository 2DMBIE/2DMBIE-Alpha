extends RigidBody2D



func _on_bullet_body_entered(body):
	if !body.is_in_group("player"):
		queue_free()
	
	if body.is_in_group("enemies"):
		print ("hit")

