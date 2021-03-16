extends KinematicBody2D

var velocity = Vector2(0,0)

const UP = Vector2(0, -1)
var GRAVITY = 20
const WALK_ACCELERATION = 25 #old 20
const RUN_ACCELERATION = 20
const MAX_WALK_SPEED = 130 #old 110 
const MAX_RUN_SPEED = 330
const JUMP_HEIGHT = -550
const dropthroughBit = 5

var motion = Vector2()
var is_running = false
var facing = "right"
var collision

func _ready():
	$AnimationTree.active = true

func _physics_process(_delta):
	motion.y += GRAVITY
	var friction = false

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
		elif is_running == false:
			$AnimationTree.set("parameters/running/current", 1)
			motion.x -= WALK_ACCELERATION
			motion.x = max(motion.x, -MAX_WALK_SPEED)
			$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
			if (aim("walking") == false):
				direction("left")
				$AnimationTree.set("parameters/aim/blend_position", 0)
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
		elif is_running == false: 
			$AnimationTree.set("parameters/running/current", 1)
			motion.x += WALK_ACCELERATION
			motion.x = min(motion.x, MAX_WALK_SPEED)
			$AnimationTree.set("parameters/walk-idle/blend_amount", 0)
			if (aim("walking") == false):
				direction("right")
				$AnimationTree.set("parameters/aim/blend_position", 0)
			if (get_direction() == "left") && (motion.x > 0):
				$AnimationTree.set("parameters/moonwalking/current", 0)
			else: 
				$AnimationTree.set("parameters/moonwalking/current", 1)
	elif not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
		if (aim("walking") == false): 
			$AnimationTree.set("parameters/aim/blend_position", 0)
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
		$CollisionShape2D.disabled = true
		$CollisionShape2DCrouch.disabled = false
		motion.x = lerp(motion.x, motion.x/10, .3)
	else:
		$AnimationTree.set("parameters/crouching/current", 1)
		$CollisionShape2D.disabled = false
		$CollisionShape2DCrouch.disabled = true
		scale.y = lerp(scale.y, 1, .1)
		
			
	for i in get_slide_count():
		collision = get_slide_collision(i).collider.name
#		if collision.collider.name == "Stairs" and is_on_floor() and not Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
#			GRAVITY = 0
#		else:
#			GRAVITY = 20
		
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
		var positionA = $body/chest/torso/gun/ShootVector.position
		var positionB = get_local_mouse_position()
		var angle_radians = positionA.angle_to_point(positionB)
		var angle_degrees = angle_radians*180/PI
		if (angle_degrees >= -90) && (angle_degrees <= 90):
			$AnimationTree.set("parameters/aim/blend_position", angle_degrees)
			if (walking) || !is_on_floor(): 
				direction("left")
			return true
		elif (angle_degrees > 90) && (angle_degrees < 180):
			var x = 90-angle_degrees
			x = 90+x 
			$AnimationTree.set("parameters/aim/blend_position", x)
			if (walking) || !is_on_floor(): 
				direction("right")
			return true
		elif (angle_degrees > -180) && (angle_degrees < -90):
			var y = -180-angle_degrees
			$AnimationTree.set("parameters/aim/blend_position", y)
			if (walking) || !is_on_floor(): 
				direction("right")
			return true
	else:
		$AnimationTree.set("parameters/aim_state/current", 1)
		return false
#health system
export (float) var maxHealth = 1200

onready var EnemyDamage = get_node("../Zombie").enemyDamage
onready var health = maxHealth setget setHealth

signal health_updated(health)

func setHealth(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			queue_free()

func takenDamage(enemyDamage):
	setHealth(health - enemyDamage)
	updatHealtbar()
	$HealthTimer.start(10)

func _on_Timer_timeout():
	if health < maxHealth:
		health += 25
	updatHealtbar()
	$HealthTimer.start(0.2)

func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemies") && $InvulnerableTimer.is_stopped():
		takenDamage(EnemyDamage)
		$InvulnerableTimer.start(1)

func updatHealtbar():
	var percentageHP = int((float(health) / maxHealth * 100))
	get_node("healthbar/TextureProgress").value = percentageHP
	if percentageHP >= 70:
		get_node("healthbar/TextureProgress").set_tint_progress("14e114")
	elif percentageHP <= 70 and percentageHP >= 30:
		get_node("healthbar/TextureProgress").set_tint_progress("e1be32")
	else:
		get_node("healthbar/TextureProgress").set_tint_progress("e11e1e")
		emit_signal("health_updated", health)
	$HealthTimer.start(2)

func _on_GroundChecker_body_exited(_body):
	set_collision_mask_bit(dropthroughBit, true)
