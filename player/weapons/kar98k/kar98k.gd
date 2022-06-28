extends Gun

class_name KAR98K

func _init():
	name = "Kar98k" # The name of the gun.
	offset = Vector2(7.994,-1.09) # The position of the gun.
	scale = Vector2(1,1) # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	texture = load("res://player/weapons/kar98k/kar98k.png") # The path of the sprite gun.

	bulletpoint = Vector2(68.153, -6.719) # Position of the bulletpoint.
	bulletdelay = float(1.25) # The delay between each bullet. [0.1, 0.2]

	_bullet = Bullet.new(float(650), float(1700), "res://player/weapons/all_bullet_scenes/normal_bullet/bullet.tscn", int(5)) 
	# The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = load("res://player/weapons/all_bullet_scenes/muzzleflash/muzzleflash.tscn") # The scene of the muzzleflash
	
	camera_shake = float(1) # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = float(0.9) # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = float(1) # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
	maxclipAmmo = 5 # How much bullets are in one magazine.
	totalAmmo = 45 # Total ammo which comes with each gun.
	ammo = maxclipAmmo
	reload_time = float(4)
