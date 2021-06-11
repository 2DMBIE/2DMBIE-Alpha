extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if get_node("/root/Lobby"):
		if get_tree().get_network_unique_id() == 1:
			$AnimationPlayer.play("DayNightCycle")
			$AnimationPlayer.seek(6.5)
		else:
			rpc_id(1, "get_daynightcycle", get_tree().get_network_unique_id())

remote func get_daynightcycle(id):
	rpc_id(id, "set_daynightcycle", $AnimationPlayer.current_animation_position)

remote func set_daynightcycle(time):
	$AnimationPlayer.play("DayNightCycle")
	$AnimationPlayer.seek(time)

func _process(_delta):
	$cursor.position = get_global_mouse_position()
