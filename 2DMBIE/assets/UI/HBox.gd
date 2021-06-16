extends HBoxContainer

func _ready():
	if Settings.fullscreen:
		$VBox/fullscreen.pressed = true

