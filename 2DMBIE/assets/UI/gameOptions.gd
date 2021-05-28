extends HBoxContainer

func _ready():
	if Global.aim:
		$VBox/HBoxContainer/VBoxContainer/always_aim.pressed = true
	if Global.camera:
		$VBox/HBoxContainer/VBoxContainer/stable_camera.pressed = true
	if Global.brightness:
		$VBox/HBoxContainer/VBoxContainer/brighter_screen.pressed = true
	if Global.debugMode:
		$VBoxSide2/HBoxContainer/CheckButton.pressed = true
