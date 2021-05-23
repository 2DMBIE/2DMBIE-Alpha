extends Node2D

## Script Variables
# How wide and tall (should be the same amount) 1 tile of the tileset(s) is in pixels
var cell_size = 64

# The amount of tiles of how high the AI will make jump connections
var jumpHeight = 2
# The amount of tiles of how far the AI will make jump connections
var jumpDistance = 1

var tileMap
var tileMap2
var ylevel_array = []
var prevCell
var graph
var cachePointArray = []
var getClosestPoint

# Show debug lines on default
var showLines = false

# Sprite of pathfinding points
const FACE = preload("res://assets/scenes/face.tscn")

var output
var cache_file_path = "user://pathfinding_cache.ivar"

## Route the AI makes when having an end destination
func findPath(start, end):
	
	# Get the points closest to the first and last point of the route and create a path inbetween them
	var first_point = graph.get_closest_point(start)
	var finish = graph.get_closest_point(end)
	var path = graph.get_id_path(first_point, finish)
	
	# Stop path when end destination is reached
	if (len(path) == 0):
		return path
	
	# Array with all the points the enemy will pass during the route
	var actions = []
	
	# Gets the position of the last point to check if the final destination is closer to the last point then the next point
	var lastPos
	
	var floors = tileMap2.get_used_cells()
	
	# Cycles through all the points in the path
	for point in path:
		var pos = graph.get_point_position(point)
		var stat = cellType(pos, true, true)
		
		# Implement a jump in the path when identifying one
		if lastPos and lastPos[1] > pos[1] and ((lastPos[0] < pos[0] and stat[0] < 0) or (lastPos[0] > pos[0] and stat[1] < 0)):
			actions.append(null)
		
		if lastPos and lastPos[1] > pos[1] and tileMap2.world_to_map(pos) + Vector2(0, 1) in floors:
			actions.append(null)
		
		# Set lastPos to the current pos, so it can start looking at a new pos again
		lastPos = pos
		
		# When start destination is closer to the next point then closest point, go to the next point instead
		if point == path[0] and len(path) > 1:
			var nextPos = graph.get_point_position(path[1])
			if abs(nextPos.x - start.x) > pos.distance_to(nextPos):
				actions.append(pos)
		
		# When end destination is closer then closest point, go to end destination instead
		elif point == path[-1] and len(path) > 1:
			if (graph.get_point_position(path[-2]).distance_to(end) < pos.distance_to(end)):
				actions.append(pos)
		
		# Go directly to end destination when there's only 1 point in the path
		elif len(path) == 1:
			pass
		
		# Go to next point in path
		else:
			actions.append(pos)
	
	# End the path at the end destination
	actions.append(end)
	return actions

## Called when the node enters the scene tree for the first time
func _ready():	
	# Creates graph where all the pathfinding points will be saved
	graph = AStar2D.new()
	
	# Gets tilesets that the enemies can collide with
	tileMap = find_parent("Main").find_node("Blocks")
	tileMap2 = find_parent("Main").find_node("Floor")
	
	# Calls function that creates an array to improve loading times
	get_unique_ylevels()
	
	# Calls function that creates all the points
#	load_cache()
	createMap()
	
	# Calls function that connects all the points
	createConections()
	

## Create connections between the points
func createConections():
	
	# Get all points of the pathfinding system
	var points = graph.get_points()
	
	# Gets all tiles from 1 or more tilesets in an array
	var cells = tileMap2.get_used_cells()
	
	# Cycles through all points of the pathfinding graph
	for point in points:
		
		# Variables that check if there's a point they can work with
		var closestRight = -1
		var closestLeftDrop = -1
		var closestRightDrop = -1
		var pos = graph.get_point_position(point)
		var stat = cellType(pos, true, true)
		
		# Array of all points that connect both ways
		var pointsToJoin = []
		
		# Array of all points that connect only one way
		var noBiJoin = []
		
		# Cycles through all points again while still checking the same point
		for newPoint in points:
			
			# Gets position of the new point, so the position of the original point can be compared to all other new points
			var newPos = graph.get_point_position(newPoint)
			
			# Sets the new point to the new closest right point until there's no point closer on the right to be found
			if (stat[1] == 0 and newPos[1] == pos[1] and newPos[0] > pos[0]):
				if closestRight < 0 or newPos[0] < graph.get_point_position(closestRight)[0]: 
					closestRight = newPoint
			
			# Sets the new point to the new closest drop point on the left until there's no point on the bottom closer to the y level of the ledge to be found
			if (stat[0] == -1):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1]):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						closestLeftDrop = newPoint
			
			# Does the same for all floor platforms instead of just ledges
			if (tileMap2.world_to_map(pos) + Vector2(0, 1) in cells):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1] and (newPos[1] - pos[1]) <= (cell_size * jumpHeight)):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						pointsToJoin.append(newPoint)
			
			# Will found out soon
			if (newPos[1] >= pos[1] - (cell_size * jumpHeight) and newPos[1] <= pos[1] and 
				newPos[0] > pos[0] - (cell_size * (jumpDistance + 2)) and newPos[0] < pos[0]) and cellType(newPos, true, true)[1] == -1 :
					pointsToJoin.append(newPoint)
			
			
			# Sets the new point to the new closest drop point on the left until there's no point on the bottom closer to the y level of the ledge to be found
			if (stat[1] == -1):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1]):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						closestRightDrop = newPoint
			
			# Does the same for all floor platforms instead of just ledges
			if (tileMap2.world_to_map(pos) + Vector2(0, 1) in cells):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1] and (newPos[1] - pos[1]) <= (cell_size * jumpHeight)):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						pointsToJoin.append(newPoint)
			
			# Will found out soon
			if (newPos[1] >= pos[1] - (cell_size * jumpHeight) and newPos[1] <= pos[1] and 
				newPos[0] < pos[0] + (cell_size * (jumpDistance + 2)) and newPos[0] > pos[0]) and cellType(newPos, true, true)[0] == -1 :
					pointsToJoin.append(newPoint)
		
		# When the closest right point is found, place it into the bidirectional points array
		if (closestRight > 0):
			pointsToJoin.append(closestRight)
		
		# When the closest drop point on the left is found and isn't bigger then the jump height, place it into the bidirectional points array
		if (closestLeftDrop > 0):
			if (graph.get_point_position(closestLeftDrop)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestLeftDrop)
			else:
				
				# When the drop is bigger then the jump height, place it into the non bidirectional points array, so it's just a drop and not a drop + jump
				noBiJoin.append(closestLeftDrop)
		
		# When the closest drop point on the right is found and isn't bigger then the jump height, place it into the bidirectional points array
		if (closestRightDrop > 0):
			if (graph.get_point_position(closestRightDrop)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestRightDrop)
			else:
				
				# When the drop is bigger then the jump height, place it into the non bidirectional points array, so it's just a drop and not a drop + jump
				noBiJoin.append(closestRightDrop)
		
		# Connect all the points that are bidirectional
		for joinPoint in pointsToJoin:
			graph.connect_points (point, joinPoint)
		
		# Connect all the points that are non bidirectional
		for joinPoint in noBiJoin:
			graph.connect_points (point, joinPoint, false)

## Draw connections between the points
func _draw():
	# Only draws the lines if showLines is true
	if !showLines:
		return
	
	# Get all points of the pathfinding system
	var points = graph.get_points()
	
	# Gets all tiles from 1 or more tilesets in an array
	var cells = tileMap2.get_used_cells()
	
	# Cycles through all points of the pathfinding graph
	for point in points:
		
		# Variables that check if there's a point they can work with
		var closestRight = -1
		var closestLeftDrop = -1
		var closestRightDrop = -1
		var pos = graph.get_point_position(point)
		var stat = cellType(pos, true, true)
		
		# Array of all points that connect both ways
		var pointsToJoin = []
		
		# Array of all points that connect only one way
		var noBiJoin = []
		
		# Cycles through all points again while still checking the same point
		for newPoint in points:
			
			# Gets position of the new point, so the position of the original point can be compared to all other new points
			var newPos = graph.get_point_position(newPoint)
			
			# Sets the new point to the new closest right point until there's no point closer on the right to be found
			if (stat[1] == 0 and newPos[1] == pos[1] and newPos[0] > pos[0]):
				if closestRight < 0 or newPos[0] < graph.get_point_position(closestRight)[0]: 
					closestRight = newPoint
			
			# Sets the new point to the new closest drop point on the left until there's no point on the bottom closer to the y level of the ledge to be found
			if (stat[0] == -1):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1]):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						closestLeftDrop = newPoint
			
			# Does the same for all floor platforms instead of just ledges
			if (tileMap2.world_to_map(pos) + Vector2(0, 1) in cells):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1] and (newPos[1] - pos[1]) <= (cell_size * jumpHeight)):
					if closestLeftDrop < 0 or newPos[1] < graph.get_point_position(closestLeftDrop)[1]:
						pointsToJoin.append(newPoint)
			
			# Will found out soon
			if (newPos[1] >= pos[1] - (cell_size * jumpHeight) and newPos[1] <= pos[1] and 
				newPos[0] > pos[0] - (cell_size * (jumpDistance + 2)) and newPos[0] < pos[0]) and cellType(newPos, true, true)[1] == -1:
					pointsToJoin.append(newPoint)
			
			
			# Sets the new point to the new closest drop point on the right until there's no point on the bottom closer to the y level of the ledge to be found
			if (stat[1] == -1):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1]):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						closestRightDrop = newPoint
			
			# Does the same for all floor platforms instead of just ledges
			if (tileMap2.world_to_map(pos) + Vector2(0, 1) in cells):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1] and (newPos[1] - pos[1]) <= (cell_size * jumpHeight)):
					if closestRightDrop < 0 or newPos[1] < graph.get_point_position(closestRightDrop)[1]:
						pointsToJoin.append(newPoint)
			
			# Will found out soon
			if (newPos[1] >= pos[1] - (cell_size * jumpHeight) and newPos[1] <= pos[1] and 
				newPos[0] < pos[0] + (cell_size * (jumpDistance + 2)) and newPos[0] > pos[0]) and cellType(newPos, true, true)[0] == -1:
					pointsToJoin.append(newPoint)
		
		# When the closest right point is found, place it into the bidirectional points array
		if (closestRight > 0):
			pointsToJoin.append(closestRight)
		
		# When the closest drop point on the left is found and isn't bigger then the jump height, place it into the bidirectional points array
		if (closestLeftDrop > 0):
			if (graph.get_point_position(closestLeftDrop)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestLeftDrop)
			else:
				
				# When the drop is bigger then the jump height, place it into the non bidirectional points array, so it's just a drop and not a drop + jump
				noBiJoin.append(closestLeftDrop)
		
		# When the closest drop point on the right is found and isn't bigger then the jump height, place it into the bidirectional points array
		if (closestRightDrop > 0):
			if (graph.get_point_position(closestRightDrop)[1] == pos[1] + cell_size):
				pointsToJoin.append(closestRightDrop)
			else:
				
				# When the drop is bigger then the jump height, place it into the non bidirectional points array, so it's just a drop and not a drop + jump
				noBiJoin.append(closestRightDrop)
		
		# Draw the lines
		for joinPoint in pointsToJoin:
			draw_line(pos, graph.get_point_position(joinPoint), Color(255, 0, 0), 1)
		for joinPoint in noBiJoin:
			draw_line(pos, graph.get_point_position(joinPoint), Color(0, 150, 150), 1)

## Creates a point at every wall, ledge, jump and drop
func createMap():
	var space_state = get_world_2d().direct_space_state
	
	# Gets all tiles from 1 or more tilesets in an array
	var cells = tileMap.get_used_cells() + tileMap2.get_used_cells()
	
	# Loops through all the cells of the chosen tilesets
	for cell in cells:
		var stat = cellType(cell)
		
		# Creates a point on top of all tiles that indentify as a wall or a ledge
		if (stat and stat != Vector2(0, 0)):
			createPoint(cell)
			
			# Creates a point at the bottom on the left side of a drop 
			if stat[1] == -1:
				
				# Sends raycast from left of the ledge in the air to the ground
				var pos = tileMap.map_to_world(Vector2(cell[0] + 1, cell[1]))
				var pto = Vector2(pos[0], pos[1] + 1000)
				var result = space_state.intersect_ray(pos, pto)
				
				# Creates a point on top of the tile that collided with the raycast if it did collide in the first place
				if (result):
					createPoint(tileMap.world_to_map(result.position))
			
			# Creates a point at the bottom on the right side of a drop
			if stat[0] == -1:
				
				# Sends raycast from left of the ledge in the air to the ground
				var pos = tileMap.map_to_world(Vector2(cell[0] - 1, cell[1]))
				var pto = Vector2(pos[0], pos[1] + 1000)
				var result = space_state.intersect_ray(pos, pto)
				
				# Creates a point on top of the tile that collided with the raycast if it did collide in the first place
				if (result):
					createPoint(tileMap.world_to_map(result.position))
	
	# Calls the getVerticalPoints (every other block vertically in the blocks tile set) and getFloorPoints functions
	for block in ylevel_array.size() / 2:
		getVerticalPoints()
	getFloorPoints()

## Creates a point on the floor under every other point
func getVerticalPoints():
	var space_state = get_world_2d().direct_space_state
	var graphPoints = graph.get_points()
	var pointPosition
	
	# Cycles through all points of the pathfinding graph
	for point in graphPoints:
		
		# Starts an raycast from a little under the current tile downwards
		var pointPos = graph.get_point_position(point)
		var verticalPoint = space_state.intersect_ray(Vector2(pointPos[0], pointPos[1] + 128), Vector2(pointPos[0], pointPos[1] + 1000))
		
		# Get the position if the collision when the raycast collides with something
		if verticalPoint:
			pointPosition = verticalPoint["position"]
		
		# Gets all tiles from 1 or more tilesets in an array
		var cells = tileMap.get_used_cells() + tileMap2.get_used_cells()
		
		# Creates a point on top of all the tiles that collided with the raycasts,
		# as long as they aren't created inside another tile
		if pointPosition:
			if !((tileMap.world_to_map(pointPosition) - Vector2(0, 1)) in cells) and !tileMap.world_to_map(graph.get_point_position(graph.get_closest_point(pointPosition))) == tileMap.world_to_map(Vector2(pointPosition.x, pointPosition.y - 32)):
				createPoint(tileMap.world_to_map(pointPosition))
		

## Creates a point above every floor tile
func getFloorPoints():
	# Gets all tiles from the floor tileset in an array
	var floorCells = tileMap2.get_used_cells()
	
	# Cycles through all the cells in the floor tileset
	for cell in floorCells:
		
		# Creates a point on top of all of them
		createPoint(cell)

## Determines if a tile is a wall or a ledge
func cellType(pos, global = false, isAbove = false):
	# Converts coordinates in pixels to coordinates tiles
	if (global):
		pos = tileMap.world_to_map(pos)
	
	# Gets the tile right above the passed one
	if isAbove:
		pos = Vector2(pos[0], pos[1] + 1)
	
	# Gets all tiles from 1 or more tilesets in an array
	var cells = tileMap.get_used_cells() + tileMap2.get_used_cells()

	# If there's a block above the passed one, return null
	if (Vector2(pos[0], pos[1] - 1) in cells):
		return null
	
	# Indicating the cellType where x is used for checking the left side and y is used for checking the right side
	# 1 == wall, 0 == flat ground, -1 == ledge
	var results = Vector2(0, 0)

#    Checking left
	if Vector2(pos[0] - 1, pos[1] - 1) in cells:
#        if wall
		results[0] = 1
	elif !(Vector2(pos[0] - 1, pos[1]) in cells):
#        if ledge
		results[0] = -1

#    Checking right
	if Vector2(pos[0] + 1, pos[1] - 1) in cells:
#        if wall
		results[1] = 1
	elif !(Vector2(pos[0] + 1, pos[1]) in cells):
#        if ledge
		results[1] = -1
	
	return results

## Makes the actual point
func createPoint(cell):
	## Gets the tile right above the current one where to point is being created
	var above = Vector2(cell[0], cell[1] - 1)
	
	# Gets the position of the tile above in the middle instead of the top left
	var pos = tileMap.map_to_world(above) + Vector2(cell_size/2, cell_size/2)
	
	# Checks for duplicate points and removes them if they overlap with eachother
	if graph.get_points() and graph.get_point_position(graph.get_closest_point(pos)) == pos:
		return
	
	# Sprite of the point
	var face = FACE.instance()
	face.set_position(pos)
	
	# Adds child to the scene when nothing else is runnning, so it doesn't get in the way of any important processing
	call_deferred("add_child", face)
	
	# Adds point to actual A* graph
	graph.add_point(graph.get_available_point_id(), pos)

## Makes array of the amount of cells exist vertically
func get_unique_ylevels():
	
	# A for loop that checks every cell in the Blocks tileset
	for cell in tileMap.get_used_cells().size():
		
		# Gets the y value of the current cell in the for loop
		var currentCell = tileMap.get_used_cells()[cell].y
		
		# Appends into a seperate array if unique and sets to prevCell for the next cell to check if its unique or not
		if !currentCell == prevCell:
			ylevel_array.append(currentCell)
			prevCell = currentCell

## Run every frame of the game
func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		# Turn all debug things off
		if showLines:
			showLines = false
			
			# Makes lines and points invisible
			visible = false
			
			# Makes debugMenu invisible
			get_node("/root/Main/DebugOverlay/Label").visible = false
		
		# Turn all debug things on
		elif !showLines:
			showLines = true
			
			# Makes lines and point visible
			visible = true
			
			# Makes debugMenu visible
			get_node("/root/Main/DebugOverlay/Label").visible = true
	
	if Input.is_action_just_pressed("save"):
		save_cache()
	if Input.is_action_just_pressed("load"):
		load_cache()
	
	getClosestPoint = graph.get_point_position(graph.get_closest_point(get_node("/root/Main/Player").position))


func save_cache():
	var file = File.new()
	file.open(cache_file_path, File.WRITE)
	for point in graph.get_points():
		cachePointArray.append(tileMap.world_to_map(Vector2(graph.get_point_position(point).x, graph.get_point_position(point).y + 32)))
	file.store_var(cachePointArray)
	file.close()

func load_cache():
	var file = File.new()
	if file.file_exists(cache_file_path):
		file.open(cache_file_path, File.READ)
		output = file.get_var()
		for p in output.size():
			createPoint(output[p])
		file.close()
	else:
		createMap()
		save_cache()
