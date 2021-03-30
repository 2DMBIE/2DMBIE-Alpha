extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta):
	$cursor.position = get_global_mouse_position()
	if Input.is_action_just_released("game_reset"):
		var _error = get_tree().reload_current_scene()
		Global.Score = 0

		

