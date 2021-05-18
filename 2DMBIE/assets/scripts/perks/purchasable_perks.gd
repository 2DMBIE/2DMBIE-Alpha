extends Node2D

var spriteHealth = preload("res://assets/sprites/perks/health_perk.png")
var spriteMovementspeed = preload("res://assets/sprites/perks/movement_perk.png")

var spriteArray = [spriteHealth, spriteMovementspeed]
var colorArray = [Color.limegreen, Color.turquoise]
var nameArray = ["Health", "Movement speed"]
var priceArray = ["3000", "2000"]

var canBuy = false
var enoughMoney = false

var perks = [HealthPerk.new(), MovementPerk.new()]
export(int, "Health", "Movement speed") var Selected_Perk = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in perks.size():
		if perks[i].name == Selected_Perk:
			perks[i].activate(self)
	for i in spriteArray.size():
		if Selected_Perk == i:
			$Sprite.set_texture(spriteArray[i])
			$Light2D.color = (colorArray[i])
			$PerkLabelName.text = (nameArray[i])
			$PerkLabelPrice.text = (priceArray[i])


func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
#		print(canBuy)
		
	# checks if the player has enough money/score
	for joas in spriteArray.size():
		if Selected_Perk == joas:
			if Global.Score >= int(priceArray[joas]):
				enoughMoney = true
#				print(enoughMoney)
			else:
				enoughMoney = false
#				print(enoughMoney)
		
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
#		print(canBuy)
		
func _process(_delta):
	pass
	#	if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
