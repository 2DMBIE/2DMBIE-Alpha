extends Sprite

var plBullet := preload("res://assets/scenes/bullet.tscn")
var muzzleflash := preload("res://assets/scenes/muzzleflash.tscn")

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
export var bullet_delay: float = .2 

var mouse_position
var bulletpoint_position
var mouse_direction
var bullet_direction
var valid_aim = true

func _process(_delta):
	#als de player wil schieten, en waarnaartoe
	if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped():
		bulletDelayTimer.start(bullet_delay)
		var bullet := plBullet.instance()
		mouse_position = get_global_mouse_position()
		bulletpoint_position = $BulletPoint.get_global_position()
		bullet.position = bulletpoint_position
		if Input.is_action_pressed("aim") and valid_aim:
			bullet.rotation = (mouse_position - bullet.position).angle()
			mouse_direction = bullet.position.direction_to(mouse_position).normalized()
			bullet.set_direction(mouse_direction)
			var muzzleflashInstance = muzzleflash.instance()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
		elif not Input.is_action_pressed("aim"):
			var facingDir = 10
			var facing = get_node("../../../../").facing
			if facing == "right":
				facingDir = 10
			elif facing == "left":
				facingDir = -10
			bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
		
			var muzzleflashInstance = muzzleflash.instance()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)

func _on_aimzone_exited():
	valid_aim = true

func _on_aimzone_entered():
	valid_aim = false
