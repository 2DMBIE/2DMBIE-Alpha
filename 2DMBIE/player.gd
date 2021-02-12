extends KinematicBody2D

var velocity = Vector2(0,0)

func _process(delta):
	if Input.is_action_pressed("left"):
		velocity.x = -100
		$AnimationPlayer.play("walk")
	if Input.is_action_pressed("right"):
		velocity.x = 100
		$AnimationPlayer.play("walk")
	if Input.is_action_pressed("down"):
		$AnimationPlayer.stop(true)
				
	move_and_slide(velocity)
	velocity.x = lerp(velocity.x,0,0.2)
	
	
		
func standstill():
	if velocity.x == 0:
		return true
	else:
		return false
