extends Node



var spriteHealthPerk = preload("res://assets/UI/Perks/Health.png")
var spriteMovementPerk = preload("res://assets/UI/Perks/Speed.png")
var spriteReloadPerk = preload ("res://assets/UI/Perks/Reload.png")
var spriteFasterShootingPerk = preload ("res://assets/UI/Perks/FireRate.png")
var spriteArray = [spriteHealthPerk, spriteMovementPerk, spriteReloadPerk, spriteFasterShootingPerk]
var healthColor = Color(0.725490, 0, 0, 1)
var movementColor = Color(1, 0.415686, 0, 1)
var reloadColor = Color(0.345098, 0.937254, 0.278431, 1)
var fireRateColor = Color(0.317647, 0.690196, 1, 1)
var colorArray = [healthColor, fireRateColor, reloadColor, movementColor]
var nameArray = ["HealthPerk", "MovementPerk", "ReloadPerk", "FireRatePerk"]
var priceArray = ["1500", "2500", "1000", "3000"]

var canBuy = false
var enoughMoney = false
var canBuyHealth = true
var canBuyMovement = true
var canBuyAmmo = true
var canBuyFasterFireRate = true

signal perkactive(canBuyFasterFireRate)
signal perkactiveAmmo(canBuyAmmo)

onready var gunscript = get_node("../../Player/body/chest/torso/gun")

export(int, "Health perk", "Movement speed perk", "Reload perk", "Fire Rate") var Selected_Perk = 0

func _physics_process(_delta):
	
	#Healthperk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 0 and canBuyHealth:
		healthperk()
		perkInterface("HealthPerk")
		canBuyHealth = false
		for i in spriteArray.size():
			if Selected_Perk == i:
				Global.Score -= int(priceArray[i])
#		print(get_node("../../Player").maxHealth)
		
	#Movementperk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 1 and canBuyMovement:
		movementperk()
		perkInterface("MovementPerk")
		canBuyMovement = false
		for i in spriteArray.size():
			if Selected_Perk == i:
				Global.Score -= int(priceArray[i])
#		print(get_node("../../Player").MAX_WALK_SPEED)
		
	#AmmoPerk
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 2 and canBuyAmmo:
		canBuyAmmo = false
		perkInterface("ReloadPerk")
		emit_signal("perkactiveAmmo", canBuyAmmo)
		ammoperk()
		for i in spriteArray.size():
			if Selected_Perk == i:
				Global.Score -= int(priceArray[i])
		
	#Faster shooting
	if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 3 and canBuyFasterFireRate:
		canBuyFasterFireRate = false
		perkInterface("FireRatePerk")
		emit_signal("perkactive", canBuyFasterFireRate)
		fasterfirerateperk()
		for i in spriteArray.size():
			if Selected_Perk == i:
				Global.Score -= int(priceArray[i])
		
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true

# checks if the player has enough money/score
	for joas in range(spriteArray.size()):
		if Selected_Perk == joas:
			if Global.Score >= int(priceArray[joas]):
				enoughMoney = true
			else:
				enoughMoney = false

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false

func healthperk():
	get_node("../../Player").maxHealth = 2500
	get_node("../../Player").health = 2500
	
func movementperk():
	get_node("../../Player").MAX_WALK_SPEED = 200
	get_node("../../Player").MAX_RUN_SPEED = 380
	
func ammoperk():
	get_node("../../Player/body/chest/torso/gun").reloadTimer.wait_time = 1
	
func fasterfirerateperk():
	gunscript.set_gun(0)
	canBuyFasterFireRate = false

func perkInterface(perk):
	get_node("../../CanvasLayer/Interface/Perks/"+perk).visible = true

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
