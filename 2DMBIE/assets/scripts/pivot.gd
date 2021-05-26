extends Position2D

onready var parent = get_parent()
onready var cameraOffset = $CameraOffset
onready var timer = $Timer
onready var mouseAngle = get_global_mouse_position().angle()
var lookDir = "right"
var timeout = true
var pivotOffset = 20
var mousePos = 0

func _ready():
	updatePivotAngle()
	
	
func _process(_delta):
	
	timerTimeout()
#	if !Global.camera:
#		timerTimeout()
#		if mousePos > (parent.position.x - pivotOffset):
#			cameraOffset.position.x = 300
#		else:
#			cameraOffset.position.x = -300
#	else:
#		cameraOffset.position.x = 0
#
#	mousePos = get_global_mouse_position().x
	
func updatePivotAngle():
	mousePos = get_global_mouse_position().x
	if mousePos > (parent.position.x - pivotOffset) and lookDir == "left":
		cameraOffset.position.x = 300
		lookDir = "right"
	elif mousePos < (parent.position.x + pivotOffset) and lookDir == "right":
		cameraOffset.position.x = -300
		lookDir = "left"


func timerTimeout():
	if timeout == true:
		updatePivotAngle()
	elif timeout == false:
		pass
	
	if (get_global_mouse_position().x > parent.position.x - pivotOffset && get_global_mouse_position().x < parent.position.x + pivotOffset):
		timer.set_wait_time(.1)
		timer.start()
		timeout = false


func _on_Timer_timeout():
	timeout = true
