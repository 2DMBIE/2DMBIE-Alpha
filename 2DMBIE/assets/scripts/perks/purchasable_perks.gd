extends Node

onready var healthperk = get_node("HealthPerk")
onready var movementperk = get_node("MovementPerk")

#var perks = [HealthPerk.new(), MovementPerk.new()]
export(int, "Health", "Movement speed") var Selected_Perk = 0

# Called when the node enters the scene tree for the first time.
func _ready():	
	#var x = perks[Selected_Perk].activate()
	healthperk.activate()
	movementperk.activate()
