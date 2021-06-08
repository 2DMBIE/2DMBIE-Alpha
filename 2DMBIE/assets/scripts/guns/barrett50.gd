extends Gun

class_name BARRETT50

func _init():
	name = "Barrett50" # The name of the gun.
	offset = Vector2(17.236,-3.362) # The position of the gun.
	scale = Vector2(1,1) # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	texture = load("res://assets/sprites/guns/barrett50.png") # The path of the sprite gun.

	bulletpoint = Vector2(79.424, -7.527) # Position of the bulletpoint.
	bulletdelay = float(1) # The delay between each bullet. [0.1, 0.2]

	_bullet = Bullet.new(float(700), float(1700), "res://assets/scenes/bullet.tscn", int(5)) 
	# The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = load("res://assets/scenes/muzzleflash.tscn") # The scene of the muzzleflash
	
	camera_shake = float(1) # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = float(0.9) # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = float(1) # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
	maxclipAmmo = 5 # How much bullets are in one magazine.
	totalAmmo = 45 # Total ammo which comes with each gun.
	ammo = maxclipAmmo
	reload_time = float(4)
