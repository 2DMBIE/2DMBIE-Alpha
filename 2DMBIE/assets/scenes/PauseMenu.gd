extends Popup


onready var player = get_node("/root/Root/Player")
var already_paused
var selected_menu

#var player

func _ready():
	player = get_node("/root/Root/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
