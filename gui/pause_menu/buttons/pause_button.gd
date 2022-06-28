extends Button


func _on_PauseButton_mouse_entered():
	$Label.add_color_override("font_color", Color(1,1,1,1))


func _on_PauseButton_mouse_exited():
	$Label.add_color_override("font_color", Color(0.823529,0.823529,0.823529,1))
