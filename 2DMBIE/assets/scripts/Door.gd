extends Node2D


func _on_doorarea_body_entered(body):
	if body.is_in_group("player"):
		$Pricelabel.visible = true

