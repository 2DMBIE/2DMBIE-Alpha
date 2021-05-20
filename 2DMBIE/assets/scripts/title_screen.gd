extends Node2D


func _ready():
	for button in $Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])


func _on_Button_pressed(scene_to_load):
	#print(scene_to_load)
	var _x = get_tree().change_scene(scene_to_load)




func _on_ExitButton_pressed():
	get_tree().quit()
