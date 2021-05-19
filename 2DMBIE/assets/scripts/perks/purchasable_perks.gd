extends Node

var spriteHealthPerk = preload("res://assets/sprites/perks/health_perk.png")
var spriteMovementPerk = preload("res://assets/sprites/perks/movement_perk.png")
var spriteArray = [spriteHealthPerk, spriteMovementPerk]
var colorArray = [Color.limegreen, Color.turquoise]
var nameArray = ["HealthPerk", "MovementPerk"]
var priceArray = ["1500", "2500"]

var canBuy = false
var enoughMoney = false

export(int, "Health", "Movement speed") var Selected_Perk = 0

func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
#		print("player entered the area")
#		print(canBuy)

# checks if the player has enough money/score
	for joas in range(spriteArray.size()):
		if Selected_Perk == joas:
			if Global.Score >= int(priceArray[joas]):
				enoughMoney = true
#				print(enoughMoney)
			else:
				enoughMoney = false
#				print(enoughMoney)

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
#		print("player exited the area")
#		print(canBuy)

func _ready():
	$Sprite.set_texture(spriteArray[Selected_Perk])
	$Light2D.color = colorArray[Selected_Perk]
	$PerkLabelName.text = nameArray[Selected_Perk]
	$PerkLabelPrice.text = priceArray[Selected_Perk]

# Called when the node enters the scene tree for the first time.
#func _ready():	
#	#var x = perks[Selected_Perk].activate()
##	healthperk.activate()
##	movementperk.activate()
#	pass
