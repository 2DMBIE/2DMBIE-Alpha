extends Node2D

const FACE = preload("res://assets/scenes/face.tscn")

var jumpHeight = 1

var tileMap
var graph

var cell_size = 64

func _ready():
	graph = AStar2D.new()
	tileMap = find_parent("Node2D").find_node("Blocks")
	createMap()
#	connectPoints()
	
#func connectPoints():
func _draw():
	var points = graph.get_points()
	for point in points:
		var closeRight = -1
		var closeLeftDrop = -1
		var closeRightDrop = -1
		var pos = graph.get_point_position(point)
		var type = cellType(pos, true, true)
		
		var pointsToJoin = []
		var noBiJoin = []
		
		for newPoint in points:
			var newPos = graph.get_point_position(newPoint)
			if (type[1] == 0 and newPos[1] == pos[1] and newPos[0] > pos[0]):
				if closeRight < 0 or newPos[0] < graph.get_point_position(closeRight)[0]:
					closeRight = newPoint
			if (type[0] == -1):
				if (newPos[0] == pos[0] - cell_size and newPos[1] > pos[1]):
					if closeLeftDrop < 0 or newPos[1] < graph.get_point_position(closeLeftDrop)[1]:
						closeLeftDrop = newPoint
						
			if (type[1] == -1):
				if (newPos[0] == pos[0] + cell_size and newPos[1] > pos[1]):
					if closeLeftDrop < 0 or newPos[1] < graph.get_point_position(closeLeftDrop)[1]:
						closeRightDrop = newPoint
				
			
		if closeRight > 0:
			pointsToJoin.append(closeRight)
			
		if closeLeftDrop > 0:
			if (graph.get_point_position(closeLeftDrop)[1] <= pos[1] + cell_size * jumpHeight):
				pointsToJoin.append(closeLeftDrop)
			else:
				noBiJoin.append(closeLeftDrop)
			
			draw_line(pos, graph.get_point_position(closeLeftDrop), Color(255, 0, 0), 1)
			
		if closeRightDrop > 0:
			if (graph.get_point_position(closeLeftDrop)[1] <= pos[1] + cell_size * jumpHeight):
				pointsToJoin.append(closeRightDrop)
			else:
				noBiJoin.append(closeRightDrop)
				
			draw_line(pos, graph.get_point_position(closeRightDrop), Color(255, 0, 0), 1)
			
		for join in pointsToJoin:
			draw_line(pos,graph.get_point_position(join), Color(255, 0, 0), 1)
		for join in noBiJoin:
			draw_line(pos, graph.get_point_position(join), Color(255,0,0), 1)
	
func createMap():
	var space_state = get_world_2d().direct_space_state
	var cells = tileMap.get_used_cells()
	
	for cell in cells:
		var type = cellType(cell)
		
		if (type and type != Vector2(0, 0)):
			createPoint(cell)
			
			if type[1] == -1:
				var pos = tileMap.map_to_world(Vector2(cell[0] + 1, cell[1]))
				var posTo = Vector2(pos[0], pos[1] + 10000) #cast array downwards to check for tiles
				var result = space_state.intersect_ray(pos, posTo)
				if (result):
					createPoint(tileMap.world_to_map(result.position)) #map to world and world to map because of different coordinates for the two
			
			if type[0] == -1:
				var pos = tileMap.map_to_world(Vector2(cell[0] - 1, cell[1]))
				var posTo = Vector2(pos[0], pos[1] + 10000) #cast array downwards to check for tiles
				var result = space_state.intersect_ray(pos, posTo)
				if (result):
					createPoint(tileMap.world_to_map(result.position)) #map to world and world to map because of different coordinates for the two
	print(graph.get_points().size())
			
func cellType(pos, global = false, isAbove = false):
	if (global):
		pos = tileMap.world_to_map(pos)
	if isAbove:
		pos = Vector2(pos[0], pos[1] + 1)
	var cells = tileMap.get_used_cells()
	
	if (Vector2(pos[0], pos[1] - 1) in cells):
		return null
		
	var results = Vector2(0, 0)
	
	if (Vector2(pos[0] - 1, pos[1] - 1) in cells):
		results[0] = 1
	elif !(Vector2(pos[0] - 1, pos[1]) in cells):
		results[0] = -1
		
	if (Vector2(pos[0] + 1, pos[1] - 1) in cells):
		results[1] = 1
	elif !(Vector2(pos[0] + 1, pos[1]) in cells):
		results[1] = -1
	return results

func createPoint(cell):
	var above = Vector2(cell[0], cell[1] - 1)
	var pos = tileMap.map_to_world(above) + Vector2(cell_size/2, cell_size/2)
	if graph.get_points() and graph.get_point_position(graph.get_closest_point(pos)) == pos:
		return
	
	var face = FACE.instance()
	face.position = pos
	add_child(face)
	
	graph.add_point(graph.get_available_point_id(), pos)
