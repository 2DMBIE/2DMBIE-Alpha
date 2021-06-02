extends Node2D


func _ready():
	pass


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_PlayButton_button_down():
	get_node("Buttons/Main").visible = false
	get_node("Buttons/Play").visible = true


func _on_BackButton_button_down():
	get_node("Buttons/Main").visible = true
	get_node("Buttons/Play").visible = false


func _on_SinglePlayer_button_down():
	var _x = get_tree().change_scene("res://assets/scenes/level3.tscn")


func _on_Multiplayer_button_down():
	var _x = get_tree().change_scene("res://assets/scenes/lobby.tscn")


func _on_OptionsButton_button_down():
	var _x = get_tree().change_scene("res://assets/UI/OptionsMenu.tscn")
