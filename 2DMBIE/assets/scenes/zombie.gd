extends KinematicBody2D

var currentPath
var currentTarget
var pathFinder

var speed = 200
var jumpForce = 400
var gravity = 600
var padding = 2
var finishPadding = 4

var movement

func _ready():
	pathFinder = find_parent("Main").find_node("Pathfinder")
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

func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce
	
func _process(delta):
#	if Input.is_action_just_pressed("aim"):
#		repeat_me()

	if currentTarget:
		if (currentTarget[0] - padding > position[0]): # and position.distance_to(currentTarget) > padding:
			movement[0] = speed
		elif (currentTarget[0] + padding < position[0]): # and position.distance_to(currentTarget) > padding:
			movement[0] = -speed
		else:
			movement[0] = 0

		if abs(position.x - currentTarget.x) < finishPadding and is_on_floor():
			nextPoint()
	else:
		movement[0] = 0
	
	if !is_on_floor():
		movement[1] += gravity * delta
	elif movement[1] > 0:
		movement[1] = 0
	
	var _moveSlide = self.move_and_slide(movement, Vector2(0, -1))
	
func repeat_me():
	if is_on_floor():
		var space_state = get_world_2d().direct_space_state
		var playerPos = get_node("../Player").position
		var pos = Vector2(playerPos.x, playerPos.y)
		var result = space_state.intersect_ray(Vector2(pos[0], pos[1] + get_node("../Player/CollisionShape2D").shape.height/2 + 10), Vector2(pos[0], pos[1] + 1000))
		if (result):
			var goTo = result["position"]
			currentPath = pathFinder.findPath(self.position, goTo)
			nextPoint()
