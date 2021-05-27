extends Position2D

var GraphRandomPoint
var MarkerPos 
var GraphRandomPointAngle 
var markerAngle
var rotationDegree

func _process(delta):
	_on_Pathfinder_ammopouchSpawn(GraphRandomPoint)
	update()
	
func _on_Pathfinder_ammopouchSpawn(graphRandomPoint):
	GraphRandomPoint = graphRandomPoint
	var MarkerPos = get_global_position()
	var GraphRandomPointAngle = graphRandomPoint.angle()
	var markerAngle = get_global_position().angle()
	var rotationDegree = (MarkerPos.angle_to(GraphRandomPoint))
	rotation = rotationDegree
	print(rotationDegree)
	
func _draw():
	draw_line(MarkerPos, GraphRandomPoint, Color(255,0,0))
	
