extends Sprite

func _on_cursor_box_body_entered(body):
	if body.is_in_group("enemies"):
		modulate = Color.red
	if body.is_in_group("player"):
		modulate = Color.green


func _on_cursor_box_body_exited(body):
	if body.is_in_group("enemies"):
		modulate = Color.white
	if body.is_in_group("player"):
		modulate = Color.white


