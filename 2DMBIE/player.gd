extends KinematicBody2D

var velocity = Vector2(0,0)

func _ready():
	$AnimationTree.active = true

func _process(delta):
	if Input.is_action_pressed("left"):
		velocity.x = -100
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
		$torso.scale = Vector2(-1,1)
	elif Input.is_action_pressed("right"):
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
		velocity.x = 100
		$torso.scale = Vector2(1,1)
	elif Input.is_action_pressed("down"):
		pass
	walk_idle_transition()
	move_and_slide(velocity)
	velocity.x = lerp(velocity.x,0,0.2)
	
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
