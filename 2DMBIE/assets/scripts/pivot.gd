extends Position2D

onready var parent = get_parent()
onready var cameraOffset = $CameraOffset
onready var timer = $Timer
var mouseAngle = get_global_mouse_position().angle()
var lookDir = "right"
var timeout = true

func _ready():
	updatePivotAngle()
	
func _physics_process(delta):
	timerTimeout()
	
func updatePivotAngle():
	var mousePos = get_global_mouse_position().x
	if mousePos > (parent.position.x - 100) and lookDir == "left":
		cameraOffset.position.x = 300
		lookDir = "right"
	elif mousePos < (parent.position.x + 100) and lookDir == "right":
		cameraOffset.position.x = -300
		lookDir = "left"


func timerTimeout():
	if timeout == true:
		updatePivotAngle()
	elif timeout == false:
		pass
	
	if (get_global_mouse_position().x > parent.position.x - 100 && get_global_mouse_position().x < parent.position.x + 100):
		timer.set_wait_time(.1)
		timer.start()
		timeout = false


func _on_Timer_timeout():
	timeout = true
