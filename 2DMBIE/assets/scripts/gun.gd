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
var canShoot = true
var totalAmmo = 60
var maxclipammo = 30
var ammo = maxclipammo
var prevAmmo
var valid_aim = true

func _process(_delta):
	if canShoot == true:
		#als de player wil schieten, en waarnaartoe
		if Input.is_action_pressed("attack") and bulletDelayTimer.is_stopped():
			bulletDelayTimer.start(bullet_delay)
			var bullet := plBullet.instance()
			mouse_position = get_global_mouse_position()
			bulletpoint_position = $BulletPoint.get_global_position()
			bullet.position = bulletpoint_position
			if ammo > 0:
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
					ammo -= 1




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
					ammo -= 1

					#emit_signal("is_shooting", false)
		reload()

func reload():
	if totalAmmo > 0:
		if Input.is_action_just_pressed("reload") and ammo < 30:
			var reloadTimer = Timer.new()
			reloadTimer.one_shot = true
			reloadTimer.wait_time = 2
			reloadTimer.connect("timeout", self, "on_timeout_finished")
			add_child(reloadTimer)
			reloadTimer.start()
			canShoot = false

#
func on_timeout_finished():
	prevAmmo = ammo
	if totalAmmo <= maxclipammo:
		ammo = ammo + totalAmmo
		if ammo > maxclipammo:
			ammo = maxclipammo
	else:
		ammo = maxclipammo
	totalAmmo -= (maxclipammo - prevAmmo)
		
	canShoot = true
	if totalAmmo < 0:
		totalAmmo = 0

func _on_aimzone_exited():
	valid_aim = true

func _on_aimzone_entered():
	valid_aim = false
