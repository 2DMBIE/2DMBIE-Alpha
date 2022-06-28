extends Gun

class_name M249_pap

func _init():
	name = "M249pap" # The name of the gun.
	offset = Vector2(2.269,-0.071) # The position of the gun.
	scale = Vector2(.9,.9) # The scale of the gun. Default Scale 1 on 1: Vector2(1,1)
	texture = load("res://assets/sprites/guns/M249_puck_a_panch.png") # The path of the sprite gun.

	bulletpoint = Vector2(85.171, -14.423) # Position of the bulletpoint.
	bulletdelay = float(.12) # The delay between each bullet. [0.1, 0.2]

	_bullet = Bullet.new(float(240), float(1000), "res://assets/scenes/bullet_laser_pink.tscn", int(4)) 
	# The scene of the bullet. You can create it with: Bullet.new(bullet_damage [0, 500], bullet_speed [100, 1250], scene_path)
	_muzzleflash = load("res://assets/scenes/muzzleflash.tscn") # The scene of the muzzleflash
	
	camera_shake = float(0.2) # Camera shake strength [0, 1] Higher = stronger.
	camera_decay = float(1.7) # How quickly the shaking of the camera stops [0, 1]. (can be higher than 1 but not lower then zero)
	gun_recoil_sensitivity = float(0.12) # Gun recoil strength [0, 1] 1 = heaviest 0 = lowest (can't be higher then 1 or lower then 0)
	
	maxclipAmmo = 120 # How much bullets are in one magazine.
	totalAmmo = 200 #Total ammo which comes with each gun.
	ammo = maxclipAmmo
	reload_time = float(4)
