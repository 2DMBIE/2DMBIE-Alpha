extends Sprite

var plBullet := preload("res://assets/scenes/bullet.tscn")
var muzzleflash := preload("res://assets/scenes/fuzzleflash.tscn")

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
export var bullet_delay: float = .2 

func _process(_delta):
	#als de player wil schieten, en waarnaartoe
	if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped():
		bulletDelayTimer.start(bullet_delay)
		var bullet := plBullet.instance()
		var mousePosition = get_global_mouse_position()
		bullet.position = $BulletPoint.get_global_position()
		if Input.is_action_pressed("aim"):
			bullet.rotation = $BulletPoint.get_angle_to(mousePosition)
			var mouseDirection = bullet.position.direction_to(mousePosition).normalized()
			bullet.set_direction(mouseDirection)
		elif not Input.is_action_pressed("aim"):
			var facingDir = 10
			var facing = get_node("../../../../").facing
			if facing == "right":
				facingDir = 10
			elif facing == "left":
				facingDir = -10
			bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
		
		var muzzleflashInstance = muzzleflash.instance()
		muzzleflashInstance.position = $BulletPoint.get_global_position()
		get_tree().get_root().add_child(muzzleflashInstance)
		
		
		get_tree().current_scene.add_child(bullet)

