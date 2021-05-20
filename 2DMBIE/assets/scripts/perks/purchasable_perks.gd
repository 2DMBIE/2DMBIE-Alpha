extends Node

var spriteHealthPerk = preload("res://assets/sprites/perks/health_perk.png")
var spriteMovementPerk = preload("res://assets/sprites/perks/movement_perk.png")
var spriteReloadPerk = preload ("res://assets/sprites/perks/movement_perk.png")
var spriteArray = [spriteHealthPerk, spriteMovementPerk, spriteReloadPerk]
var colorArray = [Color.limegreen, Color.turquoise, Color.beige]
var nameArray = ["HealthPerk", "MovementPerk", "ReloadPerk"]
var priceArray = ["1500", "2500", "1000"]

var canBuy = false
var enoughMoney = false
var canBuyHealth = true
var canBuyMovement = true
var canBuyAmmo = true

export(int, "Health perk", "Movement speed perk", "Reload perk") var Selected_Perk = 0

func _physics_process(_delta):
	
	#Healthperk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 0 and canBuyHealth:
		healthperk()
		canBuyHealth = false
#		print(get_node("../../Player").maxHealth)
		
	#Movementperk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 1 and canBuyMovement:
		movementperk()
		canBuyMovement = false
#		print(get_node("../../Player").MAX_WALK_SPEED)
		
	#AmmoPerk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 2 and canBuyAmmo:
		ammoPerk()
		canBuyAmmo = false

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

func healthperk():
	get_node("../../Player").maxHealth = 2500
	get_node("../../Player").health = 2500
	
func movementperk():
	get_node("../../Player").MAX_WALK_SPEED = 200
	get_node("../../Player").MAX_RUN_SPEED = 380
	
func ammoPerk():
	get_node("../../Player/body/chest/torso/gun").reloadTimer.wait_time = 1.25

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
