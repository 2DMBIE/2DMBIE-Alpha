extends HBoxContainer

func _ready():
	if Settings.aim:
		$VBox/HBoxContainer/VBoxContainer/always_aim.pressed = true
	if Settings.camera:
		$VBox/HBoxContainer/VBoxContainer/stable_camera.pressed = true
	if Settings.brightness:
		$VBox/HBoxContainer/VBoxContainer/brighter_screen.pressed = true
	if Settings.debugMode:
		$VBoxSide2/HBoxContainer/CheckButton.pressed = true
	if Global.maia:
		$VBoxSide2/HBoxContainer2/CheckButton.pressed = true
