extends Sprite

func _on_cursor_box_body_entered(body):
	if body.is_in_group("enemies"):
		print("enemies")
	if body.is_in_group("player"):
		print("player")


func _on_cursor_box_body_exited(body):
	if body.is_in_group("enemies"):
		print("enemy exited")
	if body.is_in_group("player"):
		print("player exited")


