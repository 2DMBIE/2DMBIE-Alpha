extends Node2D

signal totalAmmo(gainedAmmo)

var gainedAmmo = 60

func _on_AmmoArea_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("totalAmmo", gainedAmmo)
		print("iets")
		queue_free()
	
