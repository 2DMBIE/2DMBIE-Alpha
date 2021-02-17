extends Sprite

var plBullet := preload("res://weapon/scene's/bullet.tscn")

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
export var bullet_speed = 1500
export var damage = 100
export var bullet_delay: float = 1 

func _process(delta):
	#als de player wil schieten, en waarnaartoe
	if (Input.is_action_pressed("shoot") and bulletDelayTimer.is_stopped()):
		bulletDelayTimer.start(bullet_delay)
		var bullet := plBullet.instance()
		bullet.position = $BulletPoint.get_global_position()
		bullet.rotation_degrees = rotation_degrees 
		bullet.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().current_scene.add_child(bullet)

	#waar het geweer heen kijkt
	look_at(get_global_mouse_position())
