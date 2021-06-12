extends KinematicBody2D

var currentPath
var currentTarget
var pathFinder

var speed = 75
var jumpForce = 400
var gravity = 600
var padding = 2
var finishPadding = 6 # 6 or 8 for better padding when state machine
const dropthroughBit = 5

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

puppet var puppet_pos = Vector2()
puppet var puppet_movement = Vector2()
puppet var puppet_health = int()

func _ready():
	set_network_master(1) # let the host control the zombie
	$AnimationTree.active = true
	if is_network_master():
		randomize()
		var walk_current = randi()%10 # 0 till 9
		rpc("set_animation", "parameters/walk/current", walk_current) 
		growl_timer.wait_time = _wait_time
		growl_timer.one_shot = false
		growl_timer.connect("timeout", self, "growl")
		growl_timer.autostart = true
		add_child(growl_timer)
		
		pathFinder = get_tree().get_root().get_node("World").find_node("Pathfinder")
		movement = Vector2(0, 0)
		var timer = Timer.new()
		timer.set_wait_time(.1)
		timer.set_one_shot(false)
		timer.connect("timeout", self, "repeat_me")
		add_child(timer)
		timer.start()

func nextPoint():
	if len(currentPath) == 0:
		currentTarget = null
		return
	currentTarget = currentPath.pop_front()
	if !currentTarget:
		jump()
		nextPoint()
	if (currentTarget.y - 128 > self.position.y):
		if is_on_floor():
			if get_slide_collision(0).collider.name == "Floor":
				set_collision_mask_bit(dropthroughBit, false)

func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce

func _process(delta):
	if is_network_master():
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
			rpc_unreliable("set_animation", "parameters/in_air/current", 0)
		else:
			rpc_unreliable("set_animation", "parameters/in_air/current", 1)
		if self.movement.x < 0:
			direction("left")
		elif self.movement.x > 0:
			direction("right")
		rset("puppet_movement", movement)
		rset("puppet_pos", position)
	else:
		position = puppet_pos
		movement = puppet_movement
	var _moveSlide = move_and_slide(movement, Vector2(0, -1))
	if not is_network_master():
		puppet_pos = position
		puppet_movement = movement

func repeat_me():
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state
#		var playerPos = get_global_mouse_position()
		# replace 1 with gamestate.player_id
		# use get_parent, its probably faster
		var playerPos = get_tree().root.get_node("/root/World/Players/1").position
		var pos = Vector2(playerPos.x, playerPos.y)
		var result = space_state.intersect_ray(Vector2(pos[0], pos[1] + get_tree().root.get_node("/root/World/Players/1/CollisionShape2D").shape.height/2 + 10), Vector2(pos[0], pos[1] + 1000))
		if (result):
			var goTo = result["position"]
			currentPath = pathFinder.findPath(self.position, goTo)
			nextPoint()

func direction(x):
	var body = get_node("body")
	if (x == "left") && !(body.scale == Vector2(-1,1)):
		rpc_unreliable("set_direction", Vector2(-1,1))
		#body.scale = Vector2(-1,1)
	elif (x == "right") && !(body.scale == Vector2(1,1)):
		#body.scale = Vector2(1,1)
		rpc_unreliable("set_direction", Vector2(1,1))

func growl():
	rpc("play_sound_remote", "growl")

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

#remote func Hurt2(damage):
#	_set_health(health - damage)
#	var percentage = health/maxHealth*100
#	#show_damage_animation(percentage)
#	show_damage_animation(percentage)
#	emit_signal("play_sound", "hurt")
#	#rpc("show_damage_animation", percentage)
#	#rpc("play_sound_remote", "hurt")

func kill():
	Global.Score += Global.ScoreIncrement
	queue_free()

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			Global.enemiesKilled += 1
			kill()

func _on_GroundChecker_body_exited(_body):
	set_collision_mask_bit(dropthroughBit, true)

remotesync func play_sound_remote(sound):
	emit_signal("play_sound", sound)

remotesync func set_animation(path, value):
	$AnimationTree.set(path, value)
	
remotesync func set_direction(scale):
	get_node("body").scale = scale

remotesync func hurt(damage):
	emit_signal("play_sound", "hurt")
	_set_health(health - damage)
	var percentage = health/maxHealth*100
	show_damage_animation(percentage)

