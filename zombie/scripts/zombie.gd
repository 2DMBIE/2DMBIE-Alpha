extends KinematicBody2D

var currentPath
var currentTarget
var pathFinder

var speed = Global.Speed
var jumpForce = 400
var gravity = 600
var padding = 2
var finishPadding = 6 # 6 or 8 for better padding when state machine
const dropthroughBit = 5
var headshot = false
var shapeHeadless = CapsuleShape2D.new()

var movement
var zombiestep = false
signal play_sound(library)
export (int) var growl_time_min = 5 
export (int) var growl_time_max = 12
var growl_timer = Timer.new()
var _time_diff = growl_time_max - growl_time_min 
var _wait_time = randi()%_time_diff + growl_time_min

onready var health = maxHealth setget _set_health
signal health_updated(health)
var maxHealth = Global.maxHealth
var enemyDamage = Global.EnemyDamage


func _ready():
	$AnimationTree.active = true
	$AnimationTree.set("parameters/walk/current", randi()%10)
	growl_timer.wait_time = _wait_time
	growl_timer.one_shot = false
	growl_timer.connect("timeout", self, "growl")
	growl_timer.autostart = true
	add_child(growl_timer)
	if str($body/torso/neck/head.texture) == "res://assets/sprites/zombie/head_sheet.png":
		$body/torso/neck/bloodParticles.visible = false
	
	pathFinder = find_parent("Main").find_node("Pathfinder")
	movement = Vector2(0, 0)
	var timer = Timer.new()
	timer.set_wait_time(.1)
	timer.set_one_shot(false)
	timer.connect("timeout", self, "repeat_me")
	add_child(timer)
	timer.start()
	
	shapeHeadless.radius = 24
	shapeHeadless.height = 60

func nextPoint():
	if len(currentPath) == 0:
		currentTarget = null
		return
	
	currentTarget = currentPath.pop_front()
	
	if !currentTarget:
		jump()
		nextPoint()
	
	if (currentTarget.y - 128 > self.position.y):
		if is_on_floor() && get_slide_collision(0) != null:
			if get_slide_collision(0).collider != null:
				if get_slide_collision(0).collider.name == "Floor":
					set_collision_mask_bit(dropthroughBit, false)

func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce

func _process(delta):
	checkhealth()
#	if Input.is_action_just_pressed("aim"):
#		repeat_me()
	if currentTarget:
		if (currentTarget[0] - padding > position[0]) and position.distance_to(currentTarget) > padding:
			if zombiestep:
				movement[0] = speed * 2
			else:
				movement[0] = speed
		elif (currentTarget[0] + padding < position[0]) and position.distance_to(currentTarget) > padding:
			if zombiestep:
				movement[0] = -speed * 2
			else:
				movement[0] = -speed
		else:
			movement[0] = 0
		
		if abs(position.x - currentTarget.x) < finishPadding and is_on_floor():
			nextPoint()
	
	else:
		movement[0] = 0
	
	if !is_on_floor():
		movement[1] += gravity * delta
		
	if !is_on_floor():
		$AnimationTree.set("parameters/in_air/current", 0)
	else:
		$AnimationTree.set("parameters/in_air/current", 1)
	
	var _moveSlide = self.move_and_slide(movement, Vector2(0, -1))
	if self.movement.x < 0:
		direction("left")
	elif self.movement.x > 0:
		direction("right")

func repeat_me():
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state
#		var playerPos = get_global_mouse_position()
		var playerPos = get_node("../Player").position
		var pos = Vector2(playerPos.x, playerPos.y)
		var result = space_state.intersect_ray(Vector2(pos[0], pos[1] + get_node("../Player/CollisionShape2D").shape.height/2 + 10), Vector2(pos[0], pos[1] + 1000))
		if (result):
			var goTo = result["position"]
			currentPath = pathFinder.findPath(self.position, goTo)
			nextPoint()

func direction(x):
	var body = get_node("body")
	if (x == "left") && !(body.scale == Vector2(-1,1)):
		body.scale = Vector2(-1,1)
	elif (x == "right") && !(body.scale == Vector2(1,1)):
		body.scale = Vector2(1,1)
	else: pass

func growl():
	emit_signal("play_sound", "growl")

func togglestep():
	zombiestep = !zombiestep

func show_damage_animation(_health_percentage):
	var _index
	var _array = [Color("ffcbcb"), Color("ff9f9f"), Color("ff7e7e"), Color("ff5858"), Color("ffe7e7")] #Color("ffcbcb")
	if _health_percentage < 100 and _health_percentage >= 80:
		_index = 0
	elif _health_percentage < 80 and _health_percentage >= 60:
		_index = 1
	elif _health_percentage < 60 and _health_percentage >= 40:
		_index = 2
	elif _health_percentage < 40 and _health_percentage >= 20:
		_index = 3
	elif _health_percentage < 20:
		_index = 4
	
	var _timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = 0.15
	_timer.connect("timeout", self, "_reset_module")
	add_child(_timer)
	modulate = _array[_index]
	_timer.start()

func _reset_module():
	modulate = Color("ffffff")

var bullet_damage = 0

func Hurt(damage):
	bullet_damage = damage
	if headshot == false:
		_set_health(health - damage)
		var percentage = health/maxHealth*100
		show_damage_animation(percentage)
		emit_signal("play_sound", "hurt")
	else:
		_set_health(health - (damage * 2))
		var percentage = health/maxHealth*100
		show_damage_animation(percentage)
		emit_signal("play_sound", "hurt")
		Global.Score += 10
		Global.TotalScore += 10
		headshot = false

func kill():
		Global.Score += Global.ScoreIncrement
		Global.TotalScore += Global.ScoreIncrement
		Global.enemiesKilled += 1
		Global.totalEnemiesKilled += 1
		queue_free()

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()

func _on_GroundChecker_body_exited(_body):
	set_collision_mask_bit(dropthroughBit, true)

signal headroll(bulletPosition, zombie)


func _on_HeadshotArea_area_entered(area):
	if area.is_in_group("bullets"):
		headshot = true
		randomize()
		var rand = (randf())
		if rand < 0.05:
			if str($body/torso/neck/head.texture) == "res://assets/sprites/zombie/head_sheet.png":
				$body/torso/neck/bloodParticles.visible = true
			if $body/torso/neck/head.visible == true:
				$body/torso/neck/head.visible = false
				$CollisionShape2D.call_deferred("set_shape", shapeHeadless)
				$CollisionShape2D.position.y = 34
				emit_signal("headroll", area.get_parent().position + area.get_parent().velocity, self)

func checkhealth():
	$Control/TextureProgress.max_value = Global.maxHealth
	$Control/TextureProgress.value = health
	var percentageHP = int((float(health) / maxHealth * 100))
	if percentageHP == 100:
		$Control/TextureProgress.visible = false
	else:
		$Control/TextureProgress.visible = true
	if percentageHP >= 70:
		$Control/TextureProgress.set_tint_progress("14e114")
	elif percentageHP <= 70 and percentageHP >= 30:
		$Control/TextureProgress.set_tint_progress("e1be32")
	else:
		$Control/TextureProgress.set_tint_progress("e11e1e")
	
