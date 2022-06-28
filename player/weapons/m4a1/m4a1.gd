extends Gun

class_name M4A1

func _init():
	name = "M4A1" # The name of the gun.
	offset = Vector2(8.62,-2.24) # The position of the gun.
	scale = Vector2(0.9,0.9) # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	texture = load("res://player/weapons/m4a1/m4a1.png") # The path of the sprite gun.

	bulletpoint = Vector2(69.339,-8.287) # Position of the bulletpoint.
	bulletdelay = float(.175) # The delay between each bullet. [0.1, 0.2]

	_bullet = Bullet.new(float(180), float(1250), "res://player/weapons/all_bullet_scenes/normal_bullet/bullet.tscn", int(5)) 
	# The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = load("res://player/weapons/all_bullet_scenes/muzzleflash/muzzleflash.tscn") # The scene of the muzzleflash
	
	camera_shake = float(0.20) # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = float(2.2) # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = float(0.4) # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
	maxclipAmmo = 30 # How much bullets are in one magazine.
	totalAmmo = 180 # Total ammo which comes with each gun.
	ammo = maxclipAmmo
	reload_time = float(2)
