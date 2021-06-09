extends Gun

class_name SPAS12_pap

func _init():
	name = "SPAS12pap" # The name of the gun.
	offset = Vector2(10.734,-5.491) # The position of the gun.
	scale = Vector2(1,1) # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	texture = load("res://assets/sprites/guns/spas12_puck_a_panch.png") # The path of the sprite gun.

	bulletpoint = Vector2(61.589,-7.527) # Position of the bulletpoint.
	bulletdelay = float(1.5) # The delay between each bullet. [0.1, 0.2]

	_bullet = Bullet.new(float(6000), float(850), "res://assets/scenes/bullet_pellet_red.tscn", int(1)) 
	# The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = load("res://assets/scenes/muzzleflash2.tscn") # The scene of the muzzleflash
	
	camera_shake = float(0.55) # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = float(1.0) # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = float(0) # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
	maxclipAmmo = 16 # How much bullets are in one magazine.
	totalAmmo = 96 # Total ammo which comes with each gun.
	ammo = maxclipAmmo
	reload_time = float(2.5)
