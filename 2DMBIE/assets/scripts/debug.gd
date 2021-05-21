extends CanvasLayer

var stats = []

func _ready():
	add_stat("mouse_position", "Player", "mousePos", false)
	add_stat("tile_position", "Player", "tilePos", false)
	add_stat("player_speed", "Player", "motion", false)
	add_stat("get_closest_point", "Pathfinder", "getClosestPoint", false)
#	add_stat("is_running", "Player", "is_running", false)
#	add_stat("mouse_position", "Player/body/chest/torso/gun", "mouse_position", false)
#	add_stat("bulletpoint_position", "Player/body/chest/torso/gun", "bulletpoint_position", false)
#	add_stat("mouse_direction", "Player/body/chest/torso/gun", "mouse_direction", false)
#	add_stat("collision_collider", "Player", "collision", false)
	#print(get_parent().get_node("Player/body/chest/torso/gun").get("mouse_direction"))
	
func add_stat(stat_name, object, stat_ref, is_method):
	stats.append([stat_name, get_parent().get_node(object), stat_ref, is_method])
	
func _process(_delta):
	var label_text = ""
	
	
	for s in stats:
		var value = null
		if s[1] and weakref(s[1]).get_ref():
			if s[3]:
				value = s[1].call(s[2])
			else:
				value = s[1].get(s[2])
		label_text += str(s[0], ": ", value)
		label_text += "\n"
		
	$Label.text = label_text
