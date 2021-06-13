extends KinematicBody2D

onready var musicBus := AudioServer.get_bus_index("Music")
onready var musicValue

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
var is_dead = false
var _is_already_crouching = false
var running_disabled = false
var _played_crouch_sfx = false
signal play_sound(library)
var debug = false
var falling = false
var slideHold = false

var translate_color = {"Grey" : 0, "Blue" : 1, "Red" : 2, "Orange" : 3}

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()

func _ready():
	$AnimationTree.active = true
	if is_network_master():
		zombie_dam_timer = Timer.new()
		zombie_dam_timer.connect("timeout",self,"_zombie_dam_timout")
		add_child(zombie_dam_timer)
		tileMap = get_node("../../Blocks")
		emit_signal("health_updated", health, maxHealth)
		$Pivot/CameraOffset/Camera2D.current = true
		# warning-ignore:return_value_discarded
		#gamestate.connect("on_local_player_loaded", self, "on_players_loaded")

	get_node("body/chest/torso/upperarm_right/lowerarm_right/hand_right/knife").visible = false

func _physics_process(_delta):
	update()
	if is_network_master():
		musicValue = db2linear(AudioServer.get_bus_volume_db(musicBus))
		if Input.is_action_just_pressed("pause"):
			if is_dead:
				rpc("respawn")
			if get_node("Optionsmenu/Options").visible == false:
				if Global.paused == false:
					var _path = ""
					if get_tree().get_root().has_node("/root/World/Players"):
						_path = "/root/World/"
					else:
						_path = "/root/Lobby/"
					get_tree().root.get_node(_path + "CanvasModulate").set_color(Color(0.1,0.1,0.1,1))
	#				get_tree().paused = true
					Global.paused = true
					get_node("PauseMenu/Container").visible = true
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#				emit_signal("music", "pause")
					AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))
					get_node(_path + "cursor").visible = false
				elif Global.paused == true and get_node("Optionsmenu/Options").visible == false:
					unpause_game()
		escape_options()
		if !Global.paused and get_tree().root.has_node("/root/World"): #get_tree.root.has_node("/root/World") != null: #"/root/World") != null:
			if Global.brightness:
				get_tree().root.get_node("/root/World/CanvasModulate").color = Color("#bbbbbb")
			else:
				get_tree().root.get_node("/root/World/CanvasModulate").color = Color("#7f7f7f")
		if Global.paused or is_dead:
			motion.y += GRAVITY
			motion = move_and_slide(motion, UP)
			rset("puppet_motion", motion)
			rset("puppet_pos", position)
			if is_on_floor():
				rpc("jump", false)
				rpc("set_animation", "parameters/walk-idle/blend_amount", 1)
			return
		motion.y += GRAVITY
		var friction = false
		if tileMap:
			mousePos = get_global_mouse_position()
			tilePos = tileMap.world_to_map(mousePos)
			
		if motion.y > 150 and not falling:
			falling = true
		if motion.y == 20 and falling:
			rpc("onfall")
		if motion.y == 20:
			falling = false

		if Input.is_action_just_pressed("knife") and not is_knifing:
			rpc("knife")
		if running_disabled && Input.is_action_just_pressed("sprint"):
			get_node("body/chest/torso/gun").backfiring = false
			running_disabled = false
		var is_running = Input.is_action_pressed("sprint") and not running_disabled

		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			move("left", is_running)
		elif Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			move("right", is_running)
		elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			move("standstill", is_running)
			friction = true
			
			motion.x = lerp(motion.x, 0, 0.3)
			
		if is_on_floor():
			if Input.is_action_just_pressed("move_down"):
				if get_slide_collision(0).collider.name == "Floor":
					set_collision_mask_bit(dropthroughBit, false)
			rpc("jump", false)
			if Input.is_action_just_pressed("jump"):
				rpc("jump", true)
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.3)
		else:
			#aim("walking")
			if friction == true:
				motion.x = lerp(motion.x, 0, 0.05)
		var _is_standing_still = motion.x > -21 and motion.x < 21
		if Input.is_action_just_pressed("crouch") and not _is_standing_still and not is_sliding and is_on_floor():
			rpc("slide")
		if Input.is_action_pressed("crouch") and (_is_standing_still or _is_already_crouching):
			rpc("crouch", true)
		else:
			rpc("crouch", false)
		rset("puppet_motion", motion)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		motion = puppet_motion
	
	motion = move_and_slide(motion, UP)
	if not is_network_master():
		puppet_pos = position
		puppet_motion = motion
	

remotesync func direction(x):
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
	
remotesync func walk_idle_transition():
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
	
func aim(is_walking):
	if Global.aim and not Input.is_action_pressed("aim"):
		rpc_unreliable("set_animation", "parameters/aim_state/current", 1)
		return false
	else:
		rpc_unreliable("set_animation", "parameters/aim_state/current", 0)
		var positionA = $ShootVector.position
		var positionB = get_local_mouse_position()
		var angle_radians = positionA.angle_to_point(positionB)
		var angle_degrees = angle_radians*180/PI
		
		if (angle_degrees >= -90) && (angle_degrees <= 90):
			rpc_unreliable("set_aim_angle", angle_degrees)
			if (is_walking) || !is_on_floor(): 
				rpc("direction", "left")
		elif (angle_degrees > 90) && (angle_degrees < 180):
			var x = 90-angle_degrees
			x = 90+x 
			rpc_unreliable("set_aim_angle", x)
			if (is_walking) || !is_on_floor(): 
				rpc("direction", "right")
		elif (angle_degrees > -180) && (angle_degrees < -90):
			var y = -180-angle_degrees
			rpc_unreliable("set_aim_angle", y)
			if (is_walking) || !is_on_floor(): 
				rpc("direction", "right")
		return true

#health system
var maxHealth = 1200

var health = maxHealth setget setHealth

signal health_updated(health)

remotesync func die():
	is_dead = true
	is_knifing = true # disable knifing
	knifing_hitbox_enabled = false
	set_player_name("Dead")
	get_node("body/chest/torso/gun").shooting_disabled = true
	$body/chest/torso/gun.visible = false
	get_node("Hitbox").set_collision_mask_bit(3, false)
	self.set_collision_mask_bit(3, false)
	$AnimationTree.set("parameters/is_alive/current", false)
	$AnimationTree.set("parameters/torso_reset_2/blend_amount", 0)


remotesync func respawn():
	is_dead = false
	is_knifing = false
	knifing_hitbox_enabled = true
	set_player_name(gamestate.player_name)
	get_node("body/chest/torso/gun").shooting_disabled = false
	$body/chest/torso/gun.visible = true
	get_node("Hitbox").set_collision_mask_bit(3, true)
	self.set_collision_mask_bit(3, true)
	Global.Score = 0
	setHealth(maxHealth) 	# ammo and gun reset?
	$AnimationTree.set("parameters/torso_reset_2/blend_amount", 1)
	$AnimationTree.set("parameters/is_alive/current", true)

func setHealth(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health, maxHealth)
		if health == 0:
			rpc("die")

var takingDamage = false

func takenDamage(_enemyDamage):
	if is_network_master():
		setHealth(health - Global.EnemyDamage)
		$Timer.start(10)
		zombie_dam_timer.start(1.2)
		$NoDamageTimer.start(1)

func _zombie_dam_timout():
	if is_network_master():
		if takingDamage == true:
			takenDamage(Global.EnemyDamage)

func _on_Hitbox_body_entered(body):
	if is_network_master():
		if body.is_in_group("enemies") && $NoDamageTimer.is_stopped():
			takenDamage(Global.EnemyDamage)
			takingDamage = true


func _on_Hitbox_body_exited(_body):
	takingDamage = false

func _on_Timer_timeout():
	if health < maxHealth and not is_dead:
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

func _on_gun_is_shooting(value):
	rpc_unreliable("set_animation", "parameters/shooting/active", value)
	

func _on_no_aim_shoot(value):
	rpc_unreliable("set_animation","parameters/fixed_aim/current", value)

func set_gun_recoil_sensitivity(value):
	rpc("set_animation", "parameters/gun_recoil_sensitivity/add_amount", value)
	
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
		body.rpc("hurt", 300, gamestate.player_id)
		emit_signal("play_sound", "knife_hit")
		knifing_hitbox_enabled = false

func on_slide_animation_complete():
	if Input.is_action_pressed("crouch") and !slideHold:
		$AnimationPlayer.get_animation("slide").length = 1
		$AnimationPlayer.get_animation("slide").track_set_key_time(36, 0, 1)
		slideHold = true
	else:
		$AnimationTree.set("parameters/sliding/current", 1)
		$AnimationTree.set("parameters/torso_reset/blend_amount", 1)
		get_node("body/chest/torso/gun").shooting_disabled = false
		get_node("Hitbox").set_collision_mask_bit(3, true)
		self.set_collision_mask_bit(3, true)
		var _path = ""
		if get_tree().get_root().has_node("/root/World/Players"):
			_path = "/root/World/Players"
		else:
			_path = "/root/Lobby/Players"
			
		for player in get_node(_path).get_children():
			player.set_collision_mask_bit(2, true)
		knifing_hitbox_enabled = true
		is_knifing = false
		is_sliding = false
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

func _on_Hitbox_area_entered(area):
	if area.is_in_group("ammo"):
		var gainedAmmo = 60
		emit_signal("ammoPickup", gainedAmmo)
		$MarkerPos/Marker.visible = false

func _on_Pathfinder_ammopouchSpawn(_graphRandomPoint):
	$MarkerPos/Marker.visible = true


func _on_gun_set_gun_recoil_sensitivity(value):
	set_gun_recoil_sensitivity(value)
	
remotesync func set_player_name(s):
	get_node("HBoxContainer/NameTag").text = s

remotesync func knife():
	get_node("body/chest/torso/gun").visible = false
	get_node("body/chest/torso/gun").is_holding_knife = true
	get_node("body/chest/torso/upperarm_right/lowerarm_right/hand_right/knife").visible = true
	emit_signal("play_sound", "knife_swish")
	knifing_hitbox_enabled = true
	$AnimationTree.set("parameters/knifing/current", false)

remotesync func slide():
	is_sliding = true
	emit_signal("play_sound", "slide")
	$AnimationTree.set("parameters/sliding/current", 0)
	$AnimationTree.set("parameters/torso_reset/blend_amount", 0)
	get_node("body/chest/torso/gun").shooting_disabled = true # disable shooting
	is_knifing = true # disable knifing 
	get_node("Hitbox").set_collision_mask_bit(3, false)
	self.set_collision_mask_bit(3, false)
	var _path = ""
	
	if get_tree().get_root().has_node("/root/World/Players"):
		_path = "/root/World/Players"
	else:
		_path = "/root/Lobby/Players"

	for player in get_tree().root.get_node(_path).get_children():
		player.set_collision_mask_bit(2, false)
	knifing_hitbox_enabled = false
	WALK_ACCELERATION = 35 #old 20
	RUN_ACCELERATION = 40
	MAX_WALK_SPEED = 230 #old 110 
	MAX_RUN_SPEED = 430

remotesync func crouch(state):
	if state:
		_is_already_crouching = true
		if not _played_crouch_sfx:
			emit_signal("play_sound", "crouch")
			_played_crouch_sfx = true
		$AnimationTree.set("parameters/crouching/current", 0)
		if(crouch_idle):
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 0.6)
		else: 
			$AnimationTree.set("parameters/crouch-idle/blend_amount", 1.0)
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
		_is_already_crouching = false
		_played_crouch_sfx = false
		
remotesync func jump(pressed_jump):
	if pressed_jump:
		aim("walking")
		motion.y = JUMP_HEIGHT
		$AnimationTree.set("parameters/in_air_state/current", 1)
		emit_signal("play_sound", "jump")
	else:
		$AnimationTree.set("parameters/in_air_state/current", 0)

func move(m_direction, is_running):
	if m_direction == "left":
		if is_running:
			rpc_unreliable("set_animation","parameters/running/current", 0)
			rpc_unreliable("direction", "left")
			motion.x -= RUN_ACCELERATION
			motion.x = max(motion.x, -MAX_RUN_SPEED)
			if (motion.x > 50):
				motion.x = 50
			if (aim(false) == false):
				rpc_unreliable("set_aim_angle", 0)
		elif is_running == false:
			rpc_unreliable("set_animation", "parameters/running/current", 1)
			motion.x -= WALK_ACCELERATION
			motion.x = max(motion.x, -MAX_WALK_SPEED)
			rpc_unreliable("set_animation","parameters/walk-idle/blend_amount", 0)
			if (aim(true) == false):
				rpc_unreliable("direction", "left")
				rpc_unreliable("set_aim_angle", 0)
			if (get_direction() == "right") && (motion.x < 0):
				rpc_unreliable("moonwalking", 0)
			else: 
				rpc_unreliable("moonwalking", 1)
	elif m_direction == "right":
		if is_running:
			rpc_unreliable("set_animation","parameters/running/current", 0)
			rpc_unreliable("direction", "right")
			if (motion.x < -50):
				motion.x = -50
			motion.x += RUN_ACCELERATION
			motion.x = min(motion.x, MAX_RUN_SPEED)
			if(aim(false) == false):
				rpc_unreliable("set_aim_angle", 0)
		elif is_running == false: 
			rpc_unreliable("set_animation","parameters/running/current", 1)
			motion.x += WALK_ACCELERATION
			motion.x = min(motion.x, MAX_WALK_SPEED)
			rpc_unreliable("set_animation", "parameters/walk-idle/blend_amount", 0)
			if (aim(true) == false):
				rpc_unreliable("direction", "right")
				rpc_unreliable("set_aim_angle", 0)
			if (get_direction() == "left") && (motion.x > 0):
				rpc_unreliable("moonwalking", 0)
			else: 
				rpc_unreliable("moonwalking", 1)
	elif m_direction == "standstill":
		if (aim(true) == false): 
				rpc_unreliable("set_aim_angle", 0)
		rpc_unreliable("walk_idle_transition")

remotesync func onfall():
	emit_signal("play_sound", "fall")

remotesync func set_aim_angle(degrees):
	$AnimationTree.set("parameters/aim/blend_position", degrees)
	$AnimationTree.set("parameters/aim2/blend_position", degrees)
	$AnimationTree.set("parameters/shoot_angle/blend_position", degrees)

remotesync func moonwalking(x):
	$AnimationTree.set("parameters/moonwalking/current", x)

remotesync func set_animation(path, value):
	$AnimationTree.set(path, value)

enum Camo {GREY=0, BLUE=1, RED=2, ORANGE=3}
func set_color(color):
	$body/chest/torso.frame = color
	$body/chest/torso/upperarm_left.frame = color
	$body/chest/torso/upperarm_right.frame = color
	$body/chest/torso/upperarm_left/lowerarm_left.frame = color
	$body/chest/torso/upperarm_right/lowerarm_right.frame = color
	$body/legs/thigh_left.frame = color
	$body/legs/thigh_right.frame = color
	$body/legs/thigh_left/lowerleg_left.frame = color
	$body/legs/thigh_right/lowerleg_right.frame = color
	if color == Camo.GREY:
		$body/legs/thigh_left/lowerleg_left/foot_left.frame = 0
		$body/legs/thigh_right/lowerleg_right/foot_right.frame = 0
	else:
		$body/legs/thigh_left/lowerleg_left/foot_left.frame = 1
		$body/legs/thigh_right/lowerleg_right/foot_right.frame = 1
	
func unpause_game():
	var _path = ""
	if get_tree().get_root().has_node("/root/World/Players"):
		_path = "/root/World/"
	else:
		_path = "/root/Lobby/"
	get_node(_path + "CanvasModulate").set_color(Color(0.498039,0.498039,0.498039,1))
#	get_tree().paused = false
	Global.paused = false
	get_node("PauseMenu/Container").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
#	emit_signal("music", "unpause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue*4))
	get_node(_path + "cursor").visible = true

func _on_Continue_button_down():
	unpause_game()


func _on_ExitGame_button_down():
	unpause_game()
	Global.paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var _x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")

func _on_ExitOptions_button_down():
	if get_tree().get_current_scene().get_name() == 'Optionsmenu':
		var x = get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
		if x != OK:
			print("ERROR: ", x)
	else:
		get_node("Optionsmenu/Options").visible = false
	get_node("PauseMenu/Container").visible = true
#	emit_signal("music", "unpause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))

func escape_options():
#	var playerNode = "Players/"+str(gamestate.player_id)
	if get_node("Optionsmenu/Options").visible:
		if Input.is_action_pressed("escape"):
			get_node("Optionsmenu/Options").visible = false
			get_node("PauseMenu/Container").visible = true
		#	emit_signal("music", "unpause")
			AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue/4))


func _on_Options_button_down():
	get_node("PauseMenu/Container").visible = false
	get_node("Optionsmenu/Options").visible = true
	#emit_signal("music", "pause")
	AudioServer.set_bus_volume_db(musicBus, linear2db(musicValue*4))

func on_players_loaded():
	if get_tree().get_root().has_node("/root/World/Players"):
		for p in gamestate.players_info:
			get_node("/root/World/Players/" + str(p)).set_color(translate_color[gamestate.players_info[p]["Color"]])
	else:
		set_color(0)
