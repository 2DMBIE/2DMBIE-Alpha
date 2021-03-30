extends KinematicBody2D


const MAX_WALK_SPEED = 20 #old 110 
const WALK_ACCELERATION = 10 #old 20

const MAX_WALK_SPEED_STEP = 90 #old 110 
const WALK_ACCELERATION_STEP = 80 #old 20

const GRAVITY = 20
var motion = Vector2()
var zombiestep = false
var currentPath
var currentTarget
var pathFinder

var speed = 200
var jumpForce = 400
var gravity = 550
var padding = 2
var finishPadding = 90

var movement

const UP = Vector2(0, -1)
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationTree.active = true
	pathFinder = get_node("../Pathfinder")
	movement = Vector2(0, 0)
	var timer = Timer.new()
	timer.set_wait_time(3)
	timer.set_one_shot(false)
	timer.connect("timeout", self, "repeat_me")
	add_child(timer)
	timer.start()

func repeat_me():
	var space_state = get_world_2d().direct_space_state
	var playerPos = get_node("../Player").position
	var pos = Vector2(playerPos.x, playerPos.y)
	var result = space_state.intersect_ray(pos, Vector2(pos[0], pos[1] + 1000))
	if (result):
		var goTo = result["position"]
		currentPath = pathFinder.findPath(self.position, goTo)
		nextPoint()
		
func nextPoint():
	if len(currentPath) == 0:
		currentTarget = null
		return
	
	currentTarget = currentPath.pop_front()
	
	if !currentTarget:
		jump()
		nextPoint()
		
func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_pressed("left_click"):
#		var space_state = get_world_2d().direct_space_state
#		var playerPos = get_node("../Player").position
#		var pos = Vector2(playerPos.x, playerPos.y)
#		var result = space_state.intersect_ray(pos, Vector2(pos[0], pos[1] + 1000))
#		if (result):
#			var goTo = result["position"]
#			currentPath = pathFinder.findPath(self.position, goTo)
#			nextPoint()

	if !is_on_floor():
		$AnimationTree.set("parameters/in_air/current", 0)
	else:
		$AnimationTree.set("parameters/in_air/current", 1)

	if currentTarget:
		if (currentTarget[0] - padding > position[0]): # and position.distance_to(currentTarget) > padding:
			movement[0] = speed
		elif (currentTarget[0] + padding < position[0]): # and position.distance_to(currentTarget) > padding:
			movement[0] = -speed
		else:
			movement[0] = 0
			
		if position.distance_to(currentTarget) < finishPadding and is_on_floor():
				nextPoint()
	else:
		movement[0] = 0
	
	if !is_on_floor():
		movement[1] += gravity * delta
#	elif movement[1] > 0:
#		movement[1] = 0
	
	self.move_and_slide(movement, Vector2(0, -1))
#	if zombiestep:
#		motion.y += GRAVITY
#
#		motion.x += WALK_ACCELERATION_STEP
#		motion.x = min(motion.x, MAX_WALK_SPEED_STEP)
#
#		if is_on_floor():
#			motion.x = lerp(motion.x, 0, 0.3)
#		else:
#			motion.x = lerp(motion.x, 0, 0.05)
#		motion = move_and_slide(motion, UP)
#	else: 
#		motion.y += GRAVITY
#
#		motion.x += WALK_ACCELERATION
#		motion.x = min(motion.x, MAX_WALK_SPEED)
#
#		if is_on_floor():
#			motion.x = lerp(motion.x, 0, 0.3)
#		else:
#			motion.x = lerp(motion.x, 0, 0.05)
#		motion = move_and_slide(motion, UP)
		
#func togglestep():
#	zombiestep = !zombiestep
	
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

signal health_updated(health)

export (float) var maxHealth = 500
export (float) var enemyDamage = 300

onready var health = maxHealth setget _set_health

func Hurt(damage):
	_set_health(health - damage)
	var percentage = health/maxHealth*100
	show_damage_animation(percentage)

func kill():
	scale.y = .1

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
