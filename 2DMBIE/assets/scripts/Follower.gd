extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var currentPath
var currentTarget
var pathFinder

var speed = 200
var jumpForce = 300
var gravity = 550
var padding = 4
var finishPadding = 5

var movement

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinder = find_parent("Node2D").find_node("Pathfinder")
	movement = Vector2(0, 0)
	pass # Replace with function body.


func nextPoint():
	if len(currentPath) == 0:
		currentTarget = null
		return
	
	currentTarget = currentPath.pop_front()
#	print(currentTarget)
	
	if !currentTarget:
		jump()
		nextPoint()

func jump():
	if (self.is_on_floor()):
		movement[1] = -jumpForce
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if Input.is_action_just_pressed("left_click"):
	var space_state = get_world_2d().direct_space_state
	var playerPos = get_node("../Player").position
	var pos = Vector2(playerPos.x, playerPos.y + 32)
	var result = space_state.intersect_ray(pos, Vector2(pos[0], pos[1] + 1000))
	if (result):
		var goTo = result["position"]
		currentPath = pathFinder.findPath(self.position, goTo)
		nextPoint()
	
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
