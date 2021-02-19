extends KinematicBody2D

var velocity = Vector2(0,0)

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 20
const MAX_SPEED = 110 #500
const JUMP_HEIGHT = -500


var motion = Vector2()

func _ready():
	$AnimationTree.active = true

func _physics_process(delta):
	motion.y += GRAVITY
	var friction = false
	
	if Input.is_action_pressed("left"):
		motion.x -= ACCELERATION
		motion.x = max(motion.x, -MAX_SPEED)
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
		aim()
		direction("left")
		
		
	elif Input.is_action_pressed("right"):
		motion.x += ACCELERATION
		motion.x = min(motion.x, MAX_SPEED)
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
		aim()
		direction("right")
	else:
		aim()
		friction = true
		walk_idle_transition()
		motion.x = lerp(motion.x, 0, 0.3)	
		
	if is_on_floor():
		$AnimationTree.set("parameters/in_air_state/current", 0)
		if Input.is_action_just_pressed("up"):
			aim()
			motion.y = JUMP_HEIGHT
			$AnimationTree.set("parameters/in_air_state/current", 1)
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
		
	motion = move_and_slide(motion, UP)
	pass
	

func direction(x):
	if (x == "left") && !($body.scale == Vector2(-1,1)):
		$body.scale = Vector2(-1,1)
	elif (x == "right") && !($body.scale == Vector2(1,1)):
		$body.scale = Vector2(1,1)
	else: pass
		
func walk_idle_transition():
	var speed = motion.x
	if speed < 0:
		speed = speed*-1

	if (speed < 105) && (speed > 12.9): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.15)
		return
	elif (speed < 12.9) && (speed > 0.73): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.32)
		return
	elif (speed < 0.73) && (speed > 0.042): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.4) 
		return
	elif (speed < 0.042) && (speed > 0.0024): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.6)
		return
	elif (speed < 0.0024) && (speed > 0.000141): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.75)
		return
	elif (speed < 0.000141) && (speed > 0.000008): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.9)
		return
	elif (speed < 0.000008) && (speed > 0.000001): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 1)
		return
		
func aim():
	if Input.is_action_pressed("right_mousebutton"):
		$AnimationTree.set("parameters/aim_state/current", 0)
		var positionA = $ShootVector.position
		var positionB = get_local_mouse_position()
		var angle_radians = positionA.angle_to_point(positionB)
		var angle_degrees = angle_radians*180/PI
		if (angle_degrees >= -90) && (angle_degrees <= 90):
			$AnimationTree.set("parameters/aim/blend_position", angle_degrees)
			direction("left")
		elif (angle_degrees > 90) && (angle_degrees < 180):
			var x = 90-angle_degrees
			x = 90+x 
			$AnimationTree.set("parameters/aim/blend_position", x)
			direction("right")
		elif (angle_degrees > -180) && (angle_degrees < -90):
			var y = -180-angle_degrees
			$AnimationTree.set("parameters/aim/blend_position", y)
			direction("right")
	else:
		$AnimationTree.set("parameters/aim_state/current", 1)

