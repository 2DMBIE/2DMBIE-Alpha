extends Node2D


func _ready():
	for button in $Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
	
	if has_node("/root/Lobby"): # Game is in progress.
		gamestate._connected_fail()
		get_node("/root/Lobby").queue_free()
	
	$Camera2D.current = true

func _on_Button_pressed(scene_to_load):
	var _x = get_tree().change_scene(scene_to_load)

func _on_ExitButton_pressed():
	get_tree().quit()
