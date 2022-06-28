extends Button

export(String) var scene_to_load



func _on_MenuButton_mouse_entered():
	buttonOnHover()
	
func _on_MenuButton_mouse_exited():
	buttonOffHover()


func _on_ExitButton_mouse_entered():
	buttonOnHover()
	
func _on_ExitButton_mouse_exited():
	buttonOffHover()
	

func buttonOnHover():
	$ButtonTexture.scale = Vector2(0.55,0.55)

func buttonOffHover():
	$ButtonTexture.scale = Vector2(0.5,0.5)
