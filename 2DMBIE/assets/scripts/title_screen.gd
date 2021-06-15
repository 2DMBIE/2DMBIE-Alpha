extends Node2D


func _ready():	
	if has_node("/root/Lobby"): # Game is in progress.
		gamestate._connected_fail()
		get_node("/root/Lobby").queue_free()
	if has_node("/root/World"): # Game is in progress.
		gamestate._connected_fail()
		get_node("/root/World").queue_free()
	if has_node("/root/LobbyUI"): # Game is in progress.
		get_node("/root/LobbyUI").queue_free()
	$Camera2D.current = true

func _on_ExitButton_pressed():
	get_tree().quit()


func _on_PlayButton_button_down():
	get_node("Buttons/Main").visible = false
	get_node("Buttons/Play").visible = true


func _on_BackButton_button_down():
	get_node("Buttons/Main").visible = true
	get_node("Buttons/Play").visible = false


func _on_SinglePlayer_button_down():
# warning-ignore:return_value_discarded
	Global.online = false


func _on_Multiplayer_button_down():
# warning-ignore:return_value_discarded
	Global.online = true
	get_tree().change_scene("res://assets/scenes/LobbyUI.tscn")


func _on_OptionsButton_button_down():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://assets/UI/OptionsMenu.tscn")
