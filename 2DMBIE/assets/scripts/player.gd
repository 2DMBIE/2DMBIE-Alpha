extends KinematicBody2D

var velocity = Vector2(0,0)

const UP = Vector2(0, -1)
var GRAVITY = 20
const WALK_ACCELERATION = 25 #old 20
const RUN_ACCELERATION = 20
const MAX_WALK_SPEED = 130 #old 110 
const MAX_RUN_SPEED = 330
const JUMP_HEIGHT = -575
const dropthroughBit = 5

var motion = Vector2()
var is_running = false
var crouch_idle = false
var facing = "right"
var collision
var zombie_dam_timer
var tileMap
var mousePos
var tilePos

# No_aim animation -> aim animation recoil met naam: no_aim_shoot
func _ready():
	$AnimationTree.active = true
	zombie_dam_timer = Timer.new()
	zombie_dam_timer.connect("timeout",self,"_zombie_dam_timout")
	add_child(zombie_dam_timer)
	tileMap = get_node("../Blocks")
	print($CollisionShape2D.shape.height)
	emit_signal("health_updated", health, maxHealth)

func _physics_process(_delta):
	update()
	motion.y += GRAVITY
	var friction = false
	if tileMap:
		mousePos = get_global_mouse_position()
		tilePos = tileMap.world_to_map(mousePos)
	$Score.text = str("Score:") + str(Global.Score)
	#$Ammo.text = str(get_node("body/chest/torso/gun").ammo) + '/' + str(get_node("body/chest/torso/gun").maxclipammo) 
	#$maxAmmo.text = str(get_node("body/chest/torso/gun").totalAmmo)

	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if is_running:
			$AnimationTree.set("parameters/running/current", 0)
			direction("left")
			motion.x -= RUN_ACCELERATION
			motion.x = max(motion.x, -MAX_RUN_SPEED)
			if (motion.x > 50):
				motion.x = 50
			if (aim("running") == false):
				$AnimationTree.set("parameters/aim/blend_position", 0)
				$AnimationTree.set("parameters/aim2/blend_position", 0)
				$AnimationTree.set("parameters/shoot_angle/blend_position", 0)
		elif is_running == false:
			$AnimationTree.set("parameters/running/current", 1)
			motion.x -= WALK_ACCELERATION
			motion.x = max(motion.x, -MAX_WALK_SPEED)
			$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
			if (aim("walking") == false):
				direction("left")
				$AnimationTree.set("parameters/aim/blend_position", 0)
				$AnimationTree.set("parameters/aim2/blend_position", 0)
				$AnimationTree.set("parameters/shoot_angle/blend_position", 0)
			if (get_direction() == "right") && (motion.x < 0):
				$AnimationTree.set("parameters/moonwalking/current", 0)
			else: 
				$AnimationTree.set("parameters/moonwalking/current", 1)
	elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
		if is_running:
			$AnimationTree.set("parameters/running/current", 0)
			direction("right")
			if (motion.x < -50):
				motion.x = -50
			motion.x += RUN_ACCELERATION
			motion.x = min(motion.x, MAX_RUN_SPEED)
			if(aim("running") == false):
				$AnimationTree.set("parameters/aim/blend_position", 0)
				$AnimationTree.set("parameters/aim2/blend_position", 0)
				$AnimationTree.set("parameters/shoot_angle/blend_position", 0)
		elif is_running == false: 
			$AnimationTree.set("parameters/running/current", 1)
			motion.x += WALK_ACCELERATION
			motion.x = min(motion.x, MAX_WALK_SPEED)
			$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
			if (aim("walking") == false):
				direction("right")
				$AnimationTree.set("parameters/aim/blend_position", 0)
				$AnimationTree.set("parameters/aim2/blend_position", 0)
				$AnimationTree.set("parameters/shoot_angle/blend_position", 0)
			if (get_direction() == "left") && (motion.x > 0):
				$AnimationTree.set("parameters/moonwalking/current", 0)
			else: 
				$AnimationTree.set("parameters/moonwalking/current", 1)
	elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if (aim("walking") == false): 
			$AnimationTree.set("parameters/aim/blend_position", 0)
			$AnimationTree.set("parameters/aim2/blend_position", 0)
			$AnimationTree.set("parameters/shoot_angle/blend_position", 0)
		friction = true
		walk_idle_transition()
		motion.x = lerp(motion.x, 0, 0.3)
		is_running = false
		
	if is_on_floor():
		if Input.is_action_just_pressed("move_down"):
			if get_slide_collision(0).collider.name == "Floor":
				set_collision_mask_bit(dropthroughBit, false)
		$AnimationTree.set("parameters/in_air_state/current", 0)
		if Input.is_action_just_pressed("jump"):
			aim("walking")
			motion.y = JUMP_HEIGHT
			$AnimationTree.set("parameters/in_air_state/current", 1)
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
		running()
	else:
		#aim("walking")
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
			
	if Input.is_action_pressed("crouch"):
		$AnimationTree.set("parameters/crouching/current", 0)
		if(crouch_idle):
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 0.6)
		else: 
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 1)
		$CollisionShape2D.disabled = true
		$CollisionShape2DCrouch.disabled = false
		if is_on_floor():
			motion.x = 0 
	else:
		crouch_idle_transition(false)
		$AnimationTree.set("parameters/crouching/current", 1)
		$CollisionShape2D.disabled = false
		$CollisionShape2DCrouch.disabled = true
		scale.y = lerp(scale.y, 1, .1)
		
			
		
	motion = move_and_slide(motion, UP)
	pass



func direction(x):
	if (x == "left") && !($body.scale == Vector2(-1,1)):
		$body.scale = Vector2(-1,1)
		facing = "left"
	elif (x == "right") && !($body.scale == Vector2(1,1)):
		$body.scale = Vector2(1,1)
		facing = "right"
	else: pass

func get_direction():
	if ($body.scale == Vector2(-1,1)):
		return "left"
	elif ($body.scale == Vector2(1,1)):
		return "right"
	return "null"
	
func running():	
	if Input.is_action_just_pressed("sprint") and is_running == false:
		is_running = true
	elif Input.is_action_just_pressed("sprint") and is_running:
		is_running = false
		
	if Input.is_action_pressed("sprint"):
		is_running = true
			
func walk_idle_transition():
	var speed = motion.x
	if speed < 0:
		speed = speed*-1
	if (speed < 110):
		$AnimationTree.set("parameters/running/current", 1)

	if (speed < 105) && (speed > 12.9): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.15)
		return
	elif (speed < 12.9) && (speed > 0.73): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.32)
		return
	elif (speed < 0.73) && (speed > 0.042): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.4) 
		return
	elif (speed < 0.042) && (speed > 0.0024): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.6)
		return
	elif (speed < 0.0024) && (speed > 0.000141): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.75)
		return
	elif (speed < 0.000141) && (speed > 0.000008): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.9)
		return
	elif (speed < 0.000008) && !($AnimationTree.get("parameters/walk-idle/blend_amount") == 1):  #&& (speed > 0.000001): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 1)
		return
		
func aim(string):
	var walking = false
	if (string == "walking"):
		walking = true
	if Input.is_action_pressed("aim"):
		$AnimationTree.set("parameters/aim_state/current", 0)
		var positionA = $ShootVector.position
		var positionB = get_local_mouse_position()
		var angle_radians = positionA.angle_to_point(positionB)
		var angle_degrees = angle_radians*180/PI
		
		
		if (angle_degrees >= -90) && (angle_degrees <= 90):
			$AnimationTree.set("parameters/aim/blend_position", angle_degrees) 
			$AnimationTree.set("parameters/aim2/blend_position", angle_degrees)
			$AnimationTree.set("parameters/shoot_angle/blend_position", angle_degrees)
			if (walking) || !is_on_floor(): 
				direction("left")
			return true
		elif (angle_degrees > 90) && (angle_degrees < 180):
			var x = 90-angle_degrees
			x = 90+x 
			$AnimationTree.set("parameters/aim/blend_position", x)
			$AnimationTree.set("parameters/aim2/blend_position", x)
			$AnimationTree.set("parameters/shoot_angle/blend_position", x)
			if (walking) || !is_on_floor(): 
				direction("right")
			return true
		elif (angle_degrees > -180) && (angle_degrees < -90):
			var y = -180-angle_degrees
			$AnimationTree.set("parameters/aim/blend_position", y)
			$AnimationTree.set("parameters/aim2/blend_position", y)
			$AnimationTree.set("parameters/shoot_angle/blend_position", y)
			if (walking) || !is_on_floor(): 
				direction("right")
			return true
	else:
		$AnimationTree.set("parameters/aim_state/current", 1)
		return false
#health system
var maxHealth = 1200

onready var EnemyDamage = Global.EnemyDamage
onready var health = maxHealth setget setHealth

signal health_updated(health)

func kill():
	var _x = get_tree().reload_current_scene()
	Global.Score = 0
	Global.MaxWaveEnemies = 4
	Global.CurrentWaveEnemies = 0
	Global.Currentwave = 1
	Global.maxHealth = 500
	Global.EnemyDamage = 300
	Global.Speed = 200
	Global.enemiesKilled = 0 
	
func setHealth(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health, maxHealth)
		if health == 0:
			queue_free()
			kill()

var takingDamage = false

func takenDamage(_enemyDamage):
	setHealth(health - EnemyDamage)
	$Timer.start(10)
	zombie_dam_timer.start(1.2)
	$NoDamageTimer.start(1)

func _zombie_dam_timout():
	if takingDamage == true:
		takenDamage(EnemyDamage)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies") && $NoDamageTimer.is_stopped():
		takenDamage(EnemyDamage)
		takingDamage = true

func _on_Hitbox_body_exited(_body):
	takingDamage = false

func _on_Timer_timeout():
	if health < maxHealth:
		health += 25
		$Timer.start(0.2)
		emit_signal("health_updated", health, maxHealth)

#func updatHealtbar():
#	var percentageHP = int((float(health) / maxHealth * 100))
#	get_node("healthbar/TextureProgress").value = percentageHP
#	if percentageHP >= 70:
#		get_node("healthbar/TextureProgress").set_tint_progress("14e114")
#	elif percentageHP <= 70 and percentageHP >= 30:
#		get_node("healthbar/TextureProgress").set_tint_progress("e1be32")
#	else:
#		get_node("healthbar/TextureProgress").set_tint_progress("e11e1e")
#		emit_signal("health_updated", health)

func _on_groundChecker_body_exited(_body):
	set_collision_mask_bit(dropthroughBit, true)

func crouch_idle_transition(value):
	crouch_idle = value

func _on_OoBbox_area_exited(_area):
	kill()
	

func _on_gun_is_shooting(value):
	$AnimationTree.set("parameters/shooting/active", value)

func _on_no_aim_shoot(value):
	$AnimationTree.set("parameters/fixed_aim/current", value)

func _draw():
	if tileMap:
		if get_node("/root/Main/Pathfinder").showLines:
			var postA = $ShootVector.position
			var postB = get_local_mouse_position()
			draw_line(postA, postB, Color(255,0,0),1)
		else:
			pass

func set_gun_recoil_sensitivity(value):
	$AnimationTree.set("parameters/gun_recoil_sensitivity/add_amount", value)

func on_ammo_ui_update(ammo, maxClipammo, totalAmmo):
	$Ammo.text = str(ammo) + '/' + str(maxClipammo) 
	$TotalAmmo.text = str(totalAmmo)
