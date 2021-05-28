extends CanvasLayer

var debugVariables
var debugAim = debugVariables
var debugCamera = debugVariables
var debugBrightness = debugVariables

var stats = []
var properties = ['aim', 'camera', 'brightness']

func _ready():	
	add_stat("mouse_position", "Player", "mousePos", false)
	add_stat("tile_position", "Player", "tilePos", false)
	add_stat("player_speed", "Player", "motion", false)
#	add_stat("get_closest_point", "Pathfinder", "getClosestPoint", false)
	add_stat("manual_aim", "DebugOverlay", "debugAim", false)
	add_stat("moving_camera", "DebugOverlay", "debugCamera", false)
	add_stat("bright_scene", "DebugOverlay", "debugBrightness", false)
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
	
#	label_text += "manual_aim : " + str(Global.aim) + "\n"
#	label_text += "moving camera : " + str(Global.camera) + "\n" 
#	label_text += "bright_scene : " + str(Global.brightness) + "\n" 
	
	$Label.text = label_text
	
	
#	for t in range(properties.size()):
#		if Input.is_action_just_pressed("toggle" + str(t + 1)):
#			Global[properties[t]] = !Global[properties[t]]
			
	debugAim = Global[properties[0]]
	debugCamera = Global[properties[1]]
	debugBrightness = Global[properties[2]]
