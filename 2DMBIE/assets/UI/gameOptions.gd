extends VBoxContainer

func _ready():
	if Global.aim:
		$always_aim.pressed = true
	if Global.camera:
		$stable_camera.pressed = true
	if Global.brightness:
		$brighter_screen.pressed = true
