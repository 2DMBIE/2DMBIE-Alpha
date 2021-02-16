extends KinematicBody2D

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 20
const MAX_SPEED = 500
const JUMP_HEIGHT = -600

var motion = Vector2()

func _physics_process(delta):
	motion.y += GRAVITY
	var friction = false
	
	if Input.is_action_pressed("right"):
		motion.x += ACCELERATION
		motion.x = min(motion.x, MAX_SPEED)
		
	elif Input.is_action_pressed("left"):
		motion.x -= ACCELERATION
		motion.x = max(motion.x, -MAX_SPEED)
	
	else:
		friction = true
		motion.x = lerp(motion.x, 0, 0.3)
		
	if is_on_floor():
		if Input.is_action_just_pressed("up"):
			motion.y = JUMP_HEIGHT
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
			
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
		
	motion = move_and_slide(motion, UP)
	pass
