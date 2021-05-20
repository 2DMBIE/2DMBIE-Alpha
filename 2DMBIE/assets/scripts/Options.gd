extends Control


func _ready():
	pass # Replace with function body.

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
	get_node("Container/"+option).visible = true


func hideAll():
	for i in $Container.get_children():
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
