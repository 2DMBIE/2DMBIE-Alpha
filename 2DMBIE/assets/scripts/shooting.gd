extends Sprite

#onready variables
onready var bulletDelayTimer := $BulletDelayTimer

#bullet variables
signal is_shooting(value)
signal no_aim_shoot(value)
signal shake_camera(value)
signal set_camera_decay(value)
signal set_gun_recoil_sensitivity(value)
signal play_sound(value)
signal play_sound_with_pitch(value, pitch)
signal ammo_ui(ammo, maxClipammo, totalAmmo)
signal send_decay(value)
signal on_backfire_event(value)
# Gun Node2D Position:
# X 22.073
# Y -1.744

var mouse_position
var bulletpoint_position
var mouse_direction
var bullet_direction
var valid_aim = true

var current_gun_index

var weapon_slots = [0, -1]
var current_weapon = 0
var prevWeapon

var canShoot = true # Used for ammo
var is_holding_knife = false
var shooting_disabled = false
var backfiring = false

var canBuyFasterFireRate2 = true

var guns = [MP5.new(), SPAS12.new(), M4A1.new(), AK12.new(), BARRETT50.new()]
var reloadTimer = Timer.new()

func _ready():
	set_gun(weapon_slots[0])
	if is_network_master():
		self.visible = true
		reloadTimer.wait_time = 2.5
		reloadTimer.one_shot = true
		reloadTimer.connect("timeout", self, "on_reload_timeout_finished")
		add_child(reloadTimer)

func switch_slot(slot):
	if weapon_slots[slot] > -1 and !weapon_slots[slot] == prevWeapon:
		set_gun(weapon_slots[slot])             
		current_weapon = slot
		prevWeapon = weapon_slots[slot]

func _process(_delta):
	if !get_node("../../../../").paused:
		if is_network_master():
			if shooting_disabled:
				return
			
			for i in range(weapon_slots.size()):         
				if Input.is_action_just_released("weapon" + str(i + 1)):             
					switch_slot(i)

			var _gun: Gun
			_gun = get_current_gun()
			emit_signal("ammo_ui", _gun.ammo, _gun.maxclipAmmo, _gun.totalAmmo)
			#als de player wil schieten, en waarnaartoe
			if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped() and canShoot and _gun.ammo > 0 and not is_holding_knife:
				bulletDelayTimer.start()
				var bullet = _gun.getBullet() 
				mouse_position = get_global_mouse_position()
				bulletpoint_position = $BulletPoint.get_global_position()
				bullet.position = bulletpoint_position
				if Global.aim:
					if Input.is_action_pressed("aim") and valid_aim: #aiming
						emit_signal("no_aim_shoot", false)
						bullet.rotation = (mouse_position - bullet.position).angle()
						mouse_direction = bullet.position.direction_to(mouse_position).normalized()
						emit_signal("is_shooting", true)
						emit_signal("shake_camera", _gun.camera_shake)
						
						bullet.set_direction(mouse_direction)
						var muzzleflashInstance = _gun.getMuzzleFlash()
						rpc("fire_bullet", _gun.name, get_global_mouse_position(), $BulletPoint.get_global_position())
						_gun.ammo -= 1
						
						var _facing1 = get_node("../../../../").facing
						var _facing2 = get_mouse_facing()
						if _facing1 != _facing2: # The player is aiming left while r
							backfiring = true
						else:
							backfiring = false
						
						if Input.is_action_pressed("sprint") and backfiring:
							emit_signal("on_backfire_event")
					
					elif not Input.is_action_pressed("aim"): #not aiming
						emit_signal("no_aim_shoot", true)
						var facingDir = 10
						var facing = get_node("../../../../").facing
						emit_signal("is_shooting", true)
						emit_signal("shake_camera", _gun.camera_shake)
						var _scale = Vector2(1,1)
						if facing == "right":
							facingDir = 10
						elif facing == "left":
							_scale = Vector2(-1,1) # bullet trail fixed when shooting to the left
							facingDir = -10
						bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(facingDir, 0)).normalized())
						
						rpc("fire_bullet_no_aim", _gun.name, get_global_mouse_position(), $BulletPoint.get_global_position(), facingDir, _scale)
						var muzzleflashInstance = _gun.getMuzzleFlash()
						#$BulletPoint.add_child(muzzleflashInstance)
						#$BulletPoint.add_child(bullet)
						_gun.ammo -= 1
				else:
					if valid_aim:
						emit_signal("no_aim_shoot", false)
						
						bullet.rotation = (mouse_position - bullet.position).angle()
						mouse_direction = bullet.position.direction_to(mouse_position).normalized()
						emit_signal("is_shooting", true)
						emit_signal("shake_camera", _gun.camera_shake)
						
						
						bullet.set_direction(mouse_direction)
						var muzzleflashInstance = _gun.getMuzzleFlash()
						#$BulletPoint.add_child(muzzleflashInstance)
						#$BulletPoint.add_child(bullet)
						
						rpc("fire_bullet", _gun.name, get_global_mouse_position(), $BulletPoint.get_global_position())
						_gun.ammo -= 1
						
						var _facing1 = get_node("../../../../").facing
						var _facing2 = get_mouse_facing()
						if _facing1 != _facing2: # The player is aiming left while r
							backfiring = true
						else:
							backfiring = false
						
						if Input.is_action_pressed("sprint") and backfiring:
							emit_signal("on_backfire_event")
			reload()
	
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
	emit_signal("play_sound", _gun.name.to_lower() + str("_draw"))	
	
	if canBuyFasterFireRate2 == false:
		bulletDelayTimer.wait_time *= .75
		emit_signal("send_decay", 1.22)
	rpc("remote_set_gun", _gun.name)

remote func remote_set_gun(gun_name):
	for gun in guns:
		if gun.name == gun_name:
			self.texture = gun.texture
			self.scale = gun.scale
			self.offset = gun.offset
			break
			# do i need to play the gun sound?

remotesync func fire_bullet(gun_name, _global_mouse_position, _global_bullet_position):
	var _gun
	for x in guns:
		if x.name == gun_name:
			_gun = x
			break
	var bullet = _gun.getBullet() 
	#mouse_position = get_global_mouse_position()
	#bulletpoint_position = $BulletPoint.get_global_position()
	bullet.position = _global_bullet_position
	bullet.rotation = (_global_mouse_position - bullet.position).angle()
	var _mouse_direction = bullet.position.direction_to(_global_mouse_position).normalized()
	
	bullet.set_direction(_mouse_direction)
	var muzzleflashInstance = _gun.getMuzzleFlash()
	$BulletPoint.add_child(muzzleflashInstance)
	#get_tree().current_scene.add_child(bullet)
	#get_node("../..").add_child(bullet)
	emit_signal("play_sound", _gun.name.to_lower() + str("_shot"))
	get_tree().root.add_child(bullet)
		#get_tree().get_root().add_child(bullet) hetzelfde scheef
	#get_tree().root.add_child(bullet) # heel scheef maar op de goede plek

remotesync func fire_bullet_no_aim(gun_name, _global_mouse_position, _global_bullet_position, _facing_direction, _bullet_scale):
	var _gun
	for x in guns:
		if x.name == gun_name:
			_gun = x
			break
	#mouse_position = get_global_mouse_position()
	#bulletpoint_position = $BulletPoint.get_global_position()
	#bullet.position = bulletpoint_position
			
	var bullet = _gun.getBullet()
	bullet.position = _global_bullet_position
	bullet.scale = _bullet_scale
	bullet.set_direction(bullet.position.direction_to(bullet.position + Vector2(_facing_direction, 0)).normalized())
	var muzzleflashInstance = _gun.getMuzzleFlash()
	$BulletPoint.add_child(muzzleflashInstance)
	emit_signal("play_sound", _gun.name.to_lower() + str("_shot"))
	get_tree().root.add_child(bullet)

func get_current_gun():
	return guns[current_gun_index]

var reload_gun_index


func reload():
	var _gun = guns[current_gun_index]
	if _gun.totalAmmo > 0:
		if Input.is_action_just_pressed("reload") and _gun.ammo < 30 or _gun.ammo == 0:
			if canShoot:
				reload_gun_index = current_gun_index
				
				if reloadTimer.wait_time == 2.5:
					#emit_signal("play_sound", _gun.name.to_lower() + str("_reload"))
					rpc("play_sound_remote", _gun.name.to_lower() + str("_reload"))
				else:
					rpc("play_sound_remote_pitch", "mp5_reload", 2)
					#emit_signal("play_sound_with_pitch", "mp5_reload", 2)
				reloadTimer.start()
				canShoot = false

remotesync func play_sound_remote(library):
	emit_signal("play_sound", library)
	
remotesync func play_sound_remote_pitch(library, pitch):
	emit_signal("play_sound_with_pitch", library, pitch)

func on_reload_timeout_finished():
	if reload_gun_index == current_gun_index:
		var _gun = guns[current_gun_index]
		var _prevAmmo = _gun.ammo
	
		_prevAmmo = _gun.ammo
		if _gun.totalAmmo <= _gun.maxclipAmmo:
			_gun.ammo = _gun.ammo + _gun.totalAmmo
			if _gun.ammo > _gun.maxclipAmmo:
				_gun.ammo = _gun.maxclipAmmo
		else:
			_gun.ammo = _gun.maxclipAmmo
		_gun.totalAmmo -= (_gun.maxclipAmmo - _prevAmmo)
		
		canShoot = true
		if _gun.totalAmmo < 0:
			_gun.totalAmmo = 0
	else:
		canShoot = true	
	
func get_mouse_facing():
	var x1 = get_node("../../../../").position.x
	var x2 = get_global_mouse_position().x  

	if x1 > x2:
		return "left"
	else:
		return "right"


func _on_FasterShootingPerk_perkactive(canBuyFasterFireRate):
	if canBuyFasterFireRate == false:
		canBuyFasterFireRate2 = false

func _on_Player_ammoPickup(gainedAmmo):
	var _gun = guns[current_gun_index]
	_gun.totalAmmo += gainedAmmo
