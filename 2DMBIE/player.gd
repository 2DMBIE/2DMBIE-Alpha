extends KinematicBody2D

var velocity = Vector2(0,0)

const UP = Vector2(0, -1)
const GRAVITY = 20
const ACCELERATION = 20
const MAX_SPEED = 110 #500
const JUMP_HEIGHT = -600


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
		$torso.scale = Vector2(-1,1)
		
	elif Input.is_action_pressed("right"):
		motion.x += ACCELERATION
		motion.x = min(motion.x, MAX_SPEED)
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
		$torso.scale = Vector2(1,1)
		
	else:
		friction = true
		#print(motion.x)
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
	
func walk_idle_transition():
	var speed = velocity.x
	if speed < 0:
		speed = speed*-1

	if (speed < 99.0) && (speed > 10.7): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.15)
		return
	elif (speed < 10.7) && (speed > 0.92): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.32)
		return
	elif (speed < 0.92) && (speed > 0.079): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.4) 
		return
	elif (speed < 0.079) && (speed > 0.0068): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.6)
		return
	elif (speed < 0.0068) && (speed > 0.000585): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.75)
		return
	elif (speed < 0.000585) && (speed > 0.00005): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.9)
		return
	elif (speed < 0.00005) && (speed > 0.000001): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 1)
		return


