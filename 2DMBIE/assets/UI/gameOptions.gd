extends HBoxContainer

onready var aim = $VBox/HBoxContainer/VBoxContainer/always_aim
onready var camera = $VBox/HBoxContainer/VBoxContainer/stable_camera
onready var brightness = $VBox/HBoxContainer/VBoxContainer/brighter_screen
onready var debugMode = $VBoxSide2/HBoxContainer/CheckButton
onready var maia = $VBoxSide2/HBoxContainer2/CheckButton

onready var buttons = [aim, camera, brightness, debugMode]

func _ready():
	if Settings.aim:
		aim.pressed = true
	if Settings.camera:
		camera.pressed = true
	if Settings.brightness:
		brightness.pressed = true
	if Settings.debugMode:
		debugMode.pressed = true
	if Global.maia:
		maia.pressed = true

func _process(delta):
	if buttons[0].pressed == true and buttons[1].pressed == true and buttons[2].pressed == true and buttons[3].pressed == true:
		maia.visible = true
