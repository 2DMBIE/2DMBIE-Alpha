extends Sprite

var plBullet := preload("res://assets/scenes/bullet.tscn")
var muzzleflash := preload("res://assets/scenes/muzzleflash.tscn")

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
export var bullet_delay: float = .2 
signal is_shooting(value)
signal no_aim_shoot(value)
signal shake_camera(value)

var mouse_position
var bulletpoint_position
var mouse_direction
var bullet_direction
var valid_aim = true


var mp5 = Gun.new("mp5", Vector2(0,0), Vector2(1,1), "res://assets/sprites/guns/mp5.png", Vector2(41, -8.312))
var spas12 = Gun.new("spas12", Vector2(10.734,-5.491), Vector2(1,1), "res://assets/sprites/guns/spas12.png", Vector2(59.753,-8.312))
var m4a1 = Gun.new("m4a1", Vector2(10.734,-5.491), Vector2(0.9,0.9), "res://assets/sprites/guns/m4a1.png", Vector2(8.62,-2.24))
var guns = [mp5, spas12, m4a1]

func _process(_delta):
	if Input.is_action_just_released("weapon1"):
		set_gun(0)
	elif Input.is_action_just_released("weapon2"):
		set_gun(1)
	elif Input.is_action_just_released("weapon3"):
		set_gun(2)
	
	#als de player wil schieten, en waarnaartoe
	if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped():
		bulletDelayTimer.start(bullet_delay)
		var bullet := plBullet.instance()
		mouse_position = get_global_mouse_position()
		bulletpoint_position = $BulletPoint.get_global_position()
		bullet.position = bulletpoint_position
		if Input.is_action_pressed("aim") and valid_aim:
			#print("aim")
			emit_signal("no_aim_shoot", false)
			bullet.rotation = (mouse_position - bullet.position).angle()
			mouse_direction = bullet.position.direction_to(mouse_position).normalized()
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", 0.25)
			bullet.set_direction(mouse_direction)
			var muzzleflashInstance = muzzleflash.instance()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
			
		elif not Input.is_action_pressed("aim"):
			#print("no aim")
			emit_signal("no_aim_shoot", true)
			var facingDir = 10
			var facing = get_node("../../../../").facing
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", 0.25)
			if facing == "right":
				facingDir = 10
			elif facing == "left":
				bullet.scale = Vector2(-1,1) # bullet trail fixed when shooting to the left
				facingDir = -10
			bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
		
			var muzzleflashInstance = muzzleflash.instance()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
		#emit_signal("is_shooting", false)
	
func _on_aimzone_exited():
	valid_aim = true

func _on_aimzone_entered():
	valid_aim = false

func set_gun(index):
	var gun = guns[index]
	self.texture = gun.texture
	self.scale = gun.scale
	self.offset = gun.offset
	get_node("BulletPoint").position = gun.bulletpoint
	
func get_gun():
	pass
