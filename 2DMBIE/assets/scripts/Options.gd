extends Control


func _ready():
	pass # Replace with function body.

func _process(_delta):
	escape_options()

# Here can maybe go the actual functionality of the options


# Beneath is the functions of the buttons for the options menu
func _on_Audio_button_down():
	showOption('Audio')


func _on_Video_button_down():
	showOption('Video')


func _on_Controls_button_down():
	showOption('Controls')


func _on_GameOptions_button_down():
	showOption('GameOptions')

# Waht teh frick, i did not expect showOption and hideAll to work first try ;-;
func showOption(option):
	hideAll()
	get_node("Panel/VBox/Container/"+option).visible = true


func hideAll():
	for i in $Panel/VBox/Container.get_children():
		i.visible = false


# Beneath here are the hover functions
var ButtonFontHoverColor = Color(1 ,1 ,1 ,1)
var ButtonFontStandardColor = Color(0.823529 ,0.823529 ,0.823529 ,1)

func _on_Audio_mouse_entered():
	add_color_override("font_color", ButtonFontHoverColor)
func _on_Audio_mouse_exited():
	add_color_override("font_color", ButtonFontStandardColor)

func _on_Video_mouse_entered():
	add_color_override("font_color", ButtonFontHoverColor)
func _on_Video_mouse_exited():
	add_color_override("font_color", ButtonFontStandardColor)

func _on_Controls_mouse_entered():
	add_color_override("font_color", ButtonFontHoverColor)
func _on_Controls_mouse_exited():
	add_color_override("font_color", ButtonFontStandardColor)

func _on_GameOptions_mouse_entered():
	add_color_override("font_color", ButtonFontHoverColor)
func _on_GameOptions_mouse_exited():
	add_color_override("font_color", ButtonFontStandardColor)


func _on_Button_button_down():
	if get_tree().get_current_scene().get_name() == 'Optionsmenu':
		print("heolla")
		var x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
		if x != OK:
			print("Error: ", x)

func escape_options():
	if Input.is_action_pressed("escape"):
		_on_Button_button_down()


func _on_always_aim_toggled(button_pressed):
	Global.aim = button_pressed
func _on_stable_camera_toggled(button_pressed):
	Global.camera = button_pressed
func _on_brighter_screen_toggled(button_pressed):
	Global.brightness = button_pressed
