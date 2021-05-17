extends Node

var timer = Timer.new()
var count = 0
var stickykey = false

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	timer.wait_time = 0.25
	timer.connect("timeout", self, "on_timeout_complete")
	add_child(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	stickeykey()
	
func on_timeout_complete():
	count = 0
func stickeykey():
	if Input.is_action_just_pressed("shift-ctrl"):
		if (stickykey == true):
			stickykey = false
		if timer.is_stopped():
			timer.start()
			count = 1
		else:
			count += 1
			if (count == 2):
				stickykey = !stickykey
