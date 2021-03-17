extends Node2D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	print([$Floor, $Walls])

func _process(_delta):
	$cursor.position = get_global_mouse_position()
