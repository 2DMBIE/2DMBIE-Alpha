extends Sprite

var plBullet := preload("res://assets/scenes/bullet.tscn")

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
export var bullet_delay: float = 1 

func _process(_delta):
	#als de player wil schieten, en waarnaartoe
	if (Input.is_action_pressed("left_mousebutton") and bulletDelayTimer.is_stopped()):
		bulletDelayTimer.start(bullet_delay)
		var bullet := plBullet.instance()
		var mousePosition = get_global_mouse_position()
		bullet.position = $BulletPoint.get_global_position()
		bullet.rotation = $BulletPoint.get_angle_to(mousePosition)
		var mouseDirection = bullet.global_position.direction_to(mousePosition).normalized()
		bullet.set_direction(mouseDirection)
		get_tree().current_scene.add_child(bullet)

