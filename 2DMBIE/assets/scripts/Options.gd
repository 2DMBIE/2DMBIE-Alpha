extends Control

var master_bus = AudioServer.get_bus_index("Master")
var music_bus = AudioServer.get_bus_index("Music")
var soundeffects_bus = AudioServer.get_bus_index("Soundeffects")
var inputName


func _ready():
#	Settings.loadSettings()
	updateControls()
	$Panel/VBox/Container/Audio/HBox/VBox/MasterSlider.value = db2linear(AudioServer.get_bus_volume_db(master_bus))
	$Panel/VBox/Container/Audio/HBox/VBox/MusicSlider.value = db2linear(AudioServer.get_bus_volume_db(music_bus))
	$Panel/VBox/Container/Audio/HBox/VBox/SoundEffectsSlider.value = db2linear(AudioServer.get_bus_volume_db(soundeffects_bus))

func _process(_delta):
	if Input.is_action_pressed("escape"):
		escape_options()

# Here can maybe go the actual functionality of the options
func updateControls():
	for Categories in $Panel/VBox/Container/Controls/HBox/Grid.get_children():
		for Item in Categories.get_children():
			if (Item.name != 'Label'):
				Item.get_children()[1].get_children()[0].text = InputMap.get_action_list(Item.name)[0].as_text()
				if ('InputEventMouseButton' in InputMap.get_action_list(Item.name)[0].as_text()):
					Item.get_children()[1].get_children()[0].text = 'Mouse '+str(InputMap.get_action_list(Item.name)[0].button_index)


# Beneath is the functions of the buttons for the options menu
func _on_Audio_button_down():
	showOption('Audio')


func _on_Video_button_down():
	showOption('Video')


func _on_Controls_button_down():
	showOption('Controls')


func _on_GameOptions_button_down():
	showOption('GameOptions')

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


func escape_options():
	saveSettings()
	self.visible = false

signal sendHealth()

func _on_always_aim_toggled(button_pressed):
	Settings.aim = button_pressed


func _on_stable_camera_toggled(button_pressed):
	Settings.camera = button_pressed


func _on_brighter_screen_toggled(button_pressed):
	Settings.brightness = button_pressed

func _on_MasterSlider_value_changed(value):
	Settings.master_volume = value
	AudioServer.set_bus_volume_db(master_bus, linear2db(Settings.master_volume))


func _on_MusicSlider_value_changed(value):
	Settings.music_volume = value
	AudioServer.set_bus_volume_db(music_bus, linear2db(Settings.music_volume))


func _on_SoundEffectsSlider_value_changed(value):
	Settings.soundeffects_volume = value
	AudioServer.set_bus_volume_db(soundeffects_bus, linear2db(Settings.soundeffects_volume))

func saveSettings():
	var Config = File.new()
	Config.open("user://Config", File.WRITE)
	Config.store_float(Settings.master_volume)
	Config.store_float(Settings.music_volume)
	Config.store_float(Settings.soundeffects_volume)
	Config.store_var(Settings.aim)
	Config.store_var(Settings.camera)
	Config.store_var(Settings.brightness)
	Config.store_var(Settings.debugMode)
	Config.store_var(Settings.fullscreen)
	Config.close()

func _on_CheckButton_toggled(button_pressed):
	if button_pressed:
		Global.Score += 25000
	elif !button_pressed:
		Global.Score -= 25000
	
	Settings.debugMode = button_pressed
	emit_signal("sendHealth")
	
func _on_MaiaMode_toggled(button_pressed):
	Global.maia = button_pressed
	if !Settings.debugMode:
		emit_signal("sendHealth")


func _on_fullscreen_toggled(button_pressed):
	Settings.fullscreen = button_pressed
	if button_pressed:
		OS.window_fullscreen = true
	else:
		OS.window_fullscreen = false
	
