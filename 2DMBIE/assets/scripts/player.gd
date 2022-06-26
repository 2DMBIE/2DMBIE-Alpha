extends KinematicBody2D

var pivotScript = preload("res://assets/scripts/pivot.gd")

var velocity = Vector2(0,0)

const UP = Vector2(0, -1)
var GRAVITY = 20
var WALK_ACCELERATION = 25 #old 20
var RUN_ACCELERATION = 20
var MAX_WALK_SPEED = 130 #old 110 
var MAX_RUN_SPEED = 330
const JUMP_HEIGHT = -575
const dropthroughBit = 5

var motion = Vector2()
var crouch_idle = false
var facing = "right"
var collision
var zombie_dam_timer
var tileMap
var mousePos
var tilePos
var is_knifing = false
var knifing_hitbox_enabled = false
var is_sliding = false
var _is_already_crouching = false
var running_disabled = false
var _played_crouch_sfx = false
var falling = false
var slideHold = false
var groundlessjump = true
var jumpwaspressed = false
var canBuyMovement2 = true


signal play_sound(library)

func _ready():
	if Settings.debugMode:
		Global.debug = true
		maxHealth = 5000
	elif Global.maia:
		Global.debug = true
		maxHealth = 2400
	else:
		maxHealth = 1200
	_on_maxHealth_toggled()
	$AnimationTree.active = true
	zombie_dam_timer = Timer.new()
	zombie_dam_timer.connect("timeout",self,"_zombie_dam_timout")
	add_child(zombie_dam_timer)
	tileMap = get_node("../Blocks")
	emit_signal("health_updated", health, maxHealth)
	
	get_node("body/chest/torso/upperarm_right/lowerarm_right/hand_right/knife").visible = false
	

func _physics_process(_delta):
	update()

	motion.y += GRAVITY
	var friction = false
	if tileMap:
		mousePos = get_global_mouse_position()
		tilePos = tileMap.world_to_map(mousePos)
		
	if motion.y > 150 and not falling:
		falling = true
	if motion.y == 20 and falling:
		emit_signal("play_sound", "fall")
	if motion.y == 20:
		falling = false

	if Input.is_action_just_pressed("knife") and not is_knifing:
		get_node("body/chest/torso/gun").visible = false
		get_node("body/chest/torso/gun").is_holding_knife = true
		get_node("body/chest/torso/upperarm_right/lowerarm_right/hand_right/knife").visible = true
		emit_signal("play_sound", "knife_swish")
		knifing_hitbox_enabled = true
		$AnimationTree.set("parameters/knifing/current", false)
	
	if running_disabled && Input.is_action_just_pressed("sprint"):
		get_node("body/chest/torso/gun").backfiring = false
		running_disabled = false
	
	if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if is_running():
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
		elif is_running() == false:
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
		if is_running():
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
		elif is_running() == false: 
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
		
	if is_on_floor():
		groundlessjump = true
		if jumpwaspressed == true:
			aim("walking")
			motion.y = JUMP_HEIGHT
			$AnimationTree.set("parameters/in_air_state/current", 1)
			emit_signal("play_sound", "jump")
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.3)
		if Input.is_action_just_pressed("move_down"):
			if get_slide_collision(0).collider.name == "Floor":
				set_collision_mask_bit(dropthroughBit, false)
		$AnimationTree.set("parameters/in_air_state/current", 0)
		
	if Input.is_action_just_pressed("jump"):
		jumpwaspressed = true
		rememberjumptime()
		if groundlessjump == true:
			aim("walking")
			motion.y = JUMP_HEIGHT
			$AnimationTree.set("parameters/in_air_state/current", 1)
			emit_signal("play_sound", "jump")
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.3)
	
	if !is_on_floor():
		coyotejump()

	else:
		#aim("walking")
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
	var _is_standing_still = motion.x > -21 and motion.x < 21
	if (Input.is_action_just_pressed("crouch") or Global.maia) and not _is_standing_still and not is_sliding and is_on_floor():
		is_sliding = true
		emit_signal("play_sound", "slide")
		$AnimationTree.set("parameters/sliding/current", 0)
		$AnimationTree.set("parameters/torso_reset/blend_amount", 0)
		get_node("body/chest/torso/gun").shooting_disabled = true # disable shooting
		is_knifing = true # disable knifing 
		get_node("Hitbox").set_collision_mask_bit(3, false)
		get_node("Hitbox").set_collision_mask_bit(8, false)
		self.set_collision_mask_bit(3, false)
		self.set_collision_mask_bit(8, false)
		knifing_hitbox_enabled = false
#		if !Global.maia:
#			WALK_ACCELERATION = 35 #old 20
#			MAX_WALK_SPEED = 230 #old 110 
#			RUN_ACCELERATION = 40
#			MAX_RUN_SPEED = 430
		if canBuyMovement2 == false:
			WALK_ACCELERATION = 35 #old 20
			MAX_WALK_SPEED = 470 #old 110 
			RUN_ACCELERATION = 40
			MAX_RUN_SPEED = 470
		else:
			WALK_ACCELERATION = 40 #old 20
			MAX_WALK_SPEED = 430 #old 110 
			RUN_ACCELERATION = 40
			MAX_RUN_SPEED = 430
	if Global.maia and _is_standing_still and is_sliding:
		$AnimationTree.set("parameters/sliding/current", 1)
		$AnimationTree.set("parameters/torso_reset/blend_amount", 1)
		get_node("body/chest/torso/gun").shooting_disabled = false
		get_node("Hitbox").set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(8, true)
		knifing_hitbox_enabled = true
		is_knifing = false
		WALK_ACCELERATION = 25 #old 20
		RUN_ACCELERATION = 20
		MAX_WALK_SPEED = 130 #old 110 
		MAX_RUN_SPEED = 330
		slideHold = false
		is_sliding = false
	if Input.is_action_pressed("crouch") and (_is_standing_still or _is_already_crouching):
		_is_already_crouching = true
		if not _played_crouch_sfx:
			emit_signal("play_sound", "crouch")
			_played_crouch_sfx = true
		
		$AnimationTree.set("parameters/crouching/current", 0)
		if(crouch_idle):
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 0.6)
		else: 
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 1.0)
		if is_on_floor():
			motion.x = 0 
	else:
		crouch_idle_transition(false)
		$AnimationTree.set("parameters/crouching/current", 1)
		scale.y = lerp(scale.y, 1, .1)
		_is_already_crouching = false
		_played_crouch_sfx = false
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
	
func is_running():	
	if Input.is_action_pressed("sprint") and not running_disabled:
		return true
	else:
		return false

func walk_idle_transition():
	var speed = motion.x
	if speed < 0:
		speed = speed*-1
	if (speed < 110):
		$AnimationTree.set("parameters/running/current", 1)

	if (speed < 105) && (speed > 12.9): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.15)
		running_disabled = false
		return
	elif (speed < 12.9) && (speed > 0.73): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.32)
		running_disabled = false
		return
	elif (speed < 0.73) && (speed > 0.042): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.4) 
		running_disabled = false
		return
	elif (speed < 0.042) && (speed > 0.0024): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.6)
		running_disabled = false
		return
	elif (speed < 0.0024) && (speed > 0.000141): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.75)
		running_disabled = false
		return
	elif (speed < 0.000141) && (speed > 0.000008): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 0.9)
		running_disabled = false
		return
	elif (speed < 0.000008) && !($AnimationTree.get("parameters/walk-idle/blend_amount") == 1):  #&& (speed > 0.000001): 
		$AnimationTree.set("parameters/walk-idle/blend_amount", 1)
		running_disabled = false
		return
		
func aim(string):
	if Settings.aim:
		if Input.is_action_pressed("aim"):
			aim_feature(string)
			return true
		else:
			$AnimationTree.set("parameters/aim_state/current", 1)
			return false
	else:
		aim_feature(string)
		return true

func aim_feature(string):
	var walking = false
	if (string == "walking"):
		walking = true
	
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

#health system
var maxHealth = 1200

var health = maxHealth setget setHealth

signal health_updated(health)
signal on_death()

func setHealth(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health, maxHealth)
		if health == 0:
			if Global.debug:
				Global.TotalScore = 0
			Global.setHighscore()
			Global.saveScore()
			emit_signal("on_death")

func _on_maxHealth_toggled():
	if Settings.debugMode:
		Global.debug = true
		maxHealth = 5000
	elif Global.maia:
		Global.debug = true
		maxHealth = 2400
	elif !Settings.debugMode and !Global.maia:
		maxHealth = 1200
	
	health = maxHealth
	emit_signal("health_updated", health, maxHealth)


var takingDamage = false

func takenDamage(_enemyDamage):
	setHealth(health - Global.EnemyDamage)
	$Timer.start(5)
	zombie_dam_timer.start(1)
	$NoDamageTimer.start(1)

func _zombie_dam_timout():
	if takingDamage == true:
		takenDamage(Global.EnemyDamage)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies") && $NoDamageTimer.is_stopped():
		takenDamage(Global.EnemyDamage)
		takingDamage = true


func _on_Hitbox_body_exited(_body):
	takingDamage = false

func _on_Timer_timeout():
	if health < maxHealth:
		health += 25
		health = clamp(health, 0, maxHealth)
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

signal ammoUpdate(ammo, maxClipammo, totalAmmo)

func on_ammo_ui_update(ammo, maxClipammo, totalAmmo):
	emit_signal("ammoUpdate", ammo, maxClipammo, totalAmmo)

func on_knife_animation_complete():
	get_node("body/chest/torso/gun").visible = true
	get_node("body/chest/torso/upperarm_right/lowerarm_right/hand_right/knife").visible = false
	is_knifing = false
	$AnimationTree.set("parameters/knifing/current", true)
	get_node("body/chest/torso/gun").is_holding_knife = false

func on_knife_hit(body):
	if body.is_in_group("enemies") and knifing_hitbox_enabled:
		body.Hurt(500)
		if body.health == 0:
			Global.Score += 100
			Global.TotalScore += 100
		emit_signal("play_sound", "knife_hit")
		knifing_hitbox_enabled = false

func on_slide_animation_complete():
	if !Global.maia:
		if Input.is_action_pressed("crouch") and !slideHold:
			$AnimationPlayer.get_animation("slide").length = 1
			$AnimationPlayer.get_animation("slide").track_set_key_time(36, 0, 1)
			slideHold = true
		else:
			$AnimationTree.set("parameters/sliding/current", 1)
			$AnimationTree.set("parameters/torso_reset/blend_amount", 1)
			get_node("body/chest/torso/gun").shooting_disabled = false
			get_node("Hitbox").set_collision_mask_bit(3, true)
			get_node("Hitbox").set_collision_mask_bit(8, true)
			self.set_collision_mask_bit(3, true)
			self.set_collision_mask_bit(8, true)
			knifing_hitbox_enabled = true
			is_knifing = false
			if !Global.maia:
				is_sliding = false
			if canBuyMovement2 == false:
				WALK_ACCELERATION = 40 #old 20
				MAX_WALK_SPEED = 200 #old 110 
				RUN_ACCELERATION = 40
				MAX_RUN_SPEED = 380
			else:
				WALK_ACCELERATION = 25 #old 20
				RUN_ACCELERATION = 20
				MAX_WALK_SPEED = 130 #old 110 
				MAX_RUN_SPEED = 330
			$AnimationPlayer.get_animation("slide").length = .6
			$AnimationPlayer.get_animation("slide").track_set_key_time(36, 0, .6)
			slideHold = false

func _on_backfire_event():
	running_disabled = true

signal ammoPickup(totalAmmo)
onready var gunscript = get_node("body/chest/torso/gun")


func _on_Hitbox_area_entered(area):
	if area.is_in_group("ammo"):
		var gainedAmmo = gunscript.get_current_gun().maxclipAmmo
		emit_signal("ammoPickup", gainedAmmo)
		$MarkerPos/Marker.visible = false
	if area.is_in_group("Areas"):
		area.visible = false

func _on_Pathfinder_ammopouchSpawn(_graphRandomPoint):
	$MarkerPos/Marker.visible = true

func coyotejump():
	yield(get_tree().create_timer(0.1),"timeout")
	groundlessjump = false
	pass

func rememberjumptime():
	yield(get_tree().create_timer(0.1),"timeout")
	jumpwaspressed = false
	pass


func _on_MovementPerk_perkactiveMovement(canBuyMovement):
	if canBuyMovement == false:
		canBuyMovement2 = false
