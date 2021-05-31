extends HBoxContainer

func _ready():
	if Settings.aim:
		$always_aim.pressed = true
	if Settings.camera:
		$stable_camera.pressed = true
	if Settings.brightness:
		$brighter_screen.pressed = true
