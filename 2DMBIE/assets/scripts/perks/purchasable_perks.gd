extends Node

var spriteHealthPerk = preload("res://assets/sprites/perks/health_perk.png")
var spriteMovementPerk = preload("res://assets/sprites/perks/movement_perk.png")
var spriteReloadPerk = preload ("res://assets/sprites/perks/movement_perk.png")
var spriteFasterShootingPerk = preload ("res://assets/sprites/perks/movement_perk.png")
var spriteArray = [spriteHealthPerk, spriteMovementPerk, spriteReloadPerk, spriteFasterShootingPerk]
var colorArray = [Color.limegreen, Color.turquoise, Color.beige, Color.antiquewhite]
var nameArray = ["HealthPerk", "MovementPerk", "ReloadPerk", "FasterShootingPerk"]
var priceArray = ["1500", "2500", "1000", "3000"]

var canBuy = false
var enoughMoney = false
var canBuyHealth = true
var canBuyMovement = true
var canBuyAmmo = true
var canBuyFasterFireRate = true

signal perkactive(canBuyFasterFireRate)

var gunscript

export(int, "Health perk", "Movement speed perk", "Reload perk", "Faster Shooting") var Selected_Perk = 0

func _physics_process(_delta):
	if gunscript != null:
	
		#Healthperk
		if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 0 and canBuyHealth:
			healthperk()
			canBuyHealth = false
			for i in spriteArray.size():
				if Selected_Perk == i:
					Global.Score -= int(priceArray[i])
	#		print(get_node("../../Player").maxHealth)
			
		#Movementperk
		if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 1 and canBuyMovement:
			movementperk()
			canBuyMovement = false
			for i in spriteArray.size():
				if Selected_Perk == i:
					Global.Score -= int(priceArray[i])
	#		print(get_node("../../Player").MAX_WALK_SPEED)
			
		#AmmoPerk
		if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 2 and canBuyAmmo:
			ammoperk()
			canBuyAmmo = false
			for i in spriteArray.size():
				if Selected_Perk == i:
					Global.Score -= int(priceArray[i])
			
		#Faster shooting
		if Input.is_action_just_pressed("use") && canBuy and enoughMoney and Selected_Perk == 3 and canBuyFasterFireRate:
			canBuyFasterFireRate = false
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
	get_node("../../Player/body/chest/torso/gun").reloadTimer.wait_time = 1.25
	
func fasterfirerateperk():
	gunscript.set_gun(0)
	canBuyFasterFireRate = false
	
func _ready():
	$Sprite.set_texture(spriteArray[Selected_Perk])
	$Light2D.color = colorArray[Selected_Perk]
	$PerkLabelName.text = nameArray[Selected_Perk]
	$PerkLabelPrice.text = priceArray[Selected_Perk]
	
	gamestate.connect("playersLoaded", self, "_on_playersLoaded")
	
# Called when the node enters the scene tree for the first time.
#func _ready():	
#	#var x = perks[Selected_Perk].activate()
##	healthperk.activate()
##	movementperk.activate()
#	pass

func _on_playersLoaded():
	gunscript = get_node("/root/Lobby/Players/"+str(gamestate.player_id)+"/body/chest/torso/gun")
