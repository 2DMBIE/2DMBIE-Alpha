class_name Gun

# Member Variables
var name: String
var offset: Vector2
var scale: Vector2
var texture: Texture
var bulletpoint: Vector2
var bulletdelay: float

var _bullet
var _muzzleflash: PackedScene
var camera_shake: float
var camera_decay: float

var gun_recoil_sensitivity: float
#var muzzle_flash:
#Gunshake Ex. Shotgun: Heavy, m4a1: 

# Class Constructor
func _init(gun_name = "gun", gun_offset = Vector2(0,0), gun_scale = Vector2(1,1), 
path = "", bpoint = Vector2(0,0), bdelay = float(2), bullet_i = Bullet.new(float(500), float(750), "res://assets/scenes/bullet.tscn"), 
muzzleflash = load("res://assets/scenes/muzzleflash.tscn"),
 c_shake = float(0.25), c_decay = float(1.7), g_recoil = float(1)):
	
	name = gun_name # The name of the gun.
	offset = gun_offset # The position of the gun.
	scale = gun_scale # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	if not path.empty():
		texture = load(path) # The path of the sprite gun.

	bulletpoint = bpoint # Position of the bulletpoint.
	bulletdelay = bdelay # The delay between each bullet. [0.1, 0.2]

	_bullet = bullet_i # The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = muzzleflash # The scene of the muzzleflash
	
	camera_shake = c_shake # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = c_decay # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = g_recoil # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
func getBullet():
	return _bullet.getBullet()

func getMuzzleFlash():
	return _muzzleflash.instance()
