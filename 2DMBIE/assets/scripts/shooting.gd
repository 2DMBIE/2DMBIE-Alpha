extends Sprite

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
signal is_shooting(value)
signal no_aim_shoot(value)
signal shake_camera(value)
signal set_camera_decay(value)
signal set_gun_recoil_sensitivity(value)

var mouse_position
var bulletpoint_position
var mouse_direction
var bullet_direction
var valid_aim = true
var current_gun_index

var mp5 = Gun.new("mp5", Vector2(0,0), Vector2(1,1), "res://assets/sprites/guns/mp5.png", 
Vector2(41, -8.312), float(.2), Bullet.new(float(100), float(750), "res://assets/scenes/bullet.tscn"), 
load("res://assets/scenes/muzzleflash.tscn"),
float(0.25), float(1.7), float(0))

var spas12 = Gun.new("spas12", Vector2(10.734,-5.491), Vector2(1,1), "res://assets/sprites/guns/spas12.png", Vector2(59.753,-8.312), 
float(1), Bullet.new(float(100), float(750), "res://assets/scenes/bullet.tscn"), load("res://assets/scenes/muzzleflash.tscn"), float(0.50), float(1.0), float(0))

var m4a1 = Gun.new("m4a1", Vector2(8.62,-2.24), Vector2(0.9,0.9), "res://assets/sprites/guns/m4a1.png", Vector2(69.339,-8.287), 
float(.13), Bullet.new(float(50), float(1250), "res://assets/scenes/bullet.tscn"), load("res://assets/scenes/muzzleflash.tscn"), float(0.20), float(0.7), float(0.4))

var guns = [MP5.new(), spas12, m4a1]

func _ready():
	var _y = MP5.new()
	set_gun(0)

func _process(_delta):
	if Input.is_action_just_released("weapon1"):
		set_gun(0)
	elif Input.is_action_just_released("weapon2"):
		set_gun(1)
	elif Input.is_action_just_released("weapon3"):
		set_gun(2)
	
	var _gun: Gun
	_gun = get_current_gun()
	#als de player wil schieten, en waarnaartoe
	if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped():
		bulletDelayTimer.start()
		var bullet = _gun.getBullet() #plBullet.instance() 
		#bullet.get_node(".").damage = 300
		
		mouse_position = get_global_mouse_position()
		bulletpoint_position = $BulletPoint.get_global_position()
		
		bullet.position = bulletpoint_position
		if Input.is_action_pressed("aim") and valid_aim:
			#print("aim")
			emit_signal("no_aim_shoot", false)
			bullet.rotation = (mouse_position - bullet.position).angle()
			mouse_direction = bullet.position.direction_to(mouse_position).normalized()
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", _gun.camera_shake)
			bullet.set_direction(mouse_direction)
			var muzzleflashInstance = _gun.getMuzzleFlash()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
			
		elif not Input.is_action_pressed("aim"):
			#print("no aim")
			emit_signal("no_aim_shoot", true)
			var facingDir = 10
			var facing = get_node("../../../../").facing
			emit_signal("is_shooting", true)
			emit_signal("shake_camera", _gun.camera_shake)
			if facing == "right":
				facingDir = 10
			elif facing == "left":
				bullet.scale = Vector2(-1,1) # bullet trail fixed when shooting to the left
				facingDir = -10
			bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
		
			var muzzleflashInstance = _gun.getMuzzleFlash()
			$BulletPoint.add_child(muzzleflashInstance)
			get_tree().current_scene.add_child(bullet)
	
func _on_aimzone_exited():
	valid_aim = true

func _on_aimzone_entered():
	valid_aim = false

func set_gun(index):
	current_gun_index = index
	var _gun = guns[index]
	self.texture = _gun.texture
	self.scale = _gun.scale
	self.offset = _gun.offset
	bulletDelayTimer.wait_time = _gun.bulletdelay
	get_node("BulletPoint").position = _gun.bulletpoint
	emit_signal("set_camera_decay", _gun.camera_decay)
	emit_signal("set_gun_recoil_sensitivity", _gun.gun_recoil_sensitivity)
	
func get_current_gun():
	return guns[current_gun_index]
