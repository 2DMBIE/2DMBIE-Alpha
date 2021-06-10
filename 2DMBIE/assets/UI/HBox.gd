extends HBoxContainer

func ready():
	if Settings.fullscreen:
		$VBox/fullscreen.pressed = true
