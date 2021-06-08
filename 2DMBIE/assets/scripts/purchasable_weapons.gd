extends Node2D

#smg
var spriteMP5 = preload("res://assets/sprites/guns/mp5.png")
var spriteUMP45 = preload("res://assets/sprites/guns/UMP45.png")
var spriteP90 = preload("res://assets/sprites/guns/p90.png")

#shotgun
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12.png")
var spriteXM1014 = preload("res://assets/sprites/guns/XM1014.png")

#assault rifle
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12.png")

#LMG
var spriteM60 = preload("res://assets/sprites/guns/M60.png")
var spriteM249 = preload("res://assets/sprites/guns/M249.png")

#sniper
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50.png")
var spriteAWP = preload("res://assets/sprites/guns/AWP.png")
var spriteIntervention = preload("res://assets/sprites/guns/Intervention.png")

var spriteArray = [spriteMP5, spriteUMP45, spriteP90, spriteSPAS12, spriteXM1014, spriteM4A1, spriteAK12, spriteM60, spriteM249, spriteBARRETT50, spriteAWP, spriteIntervention]
var colorArray = [Color.limegreen, Color.limegreen, Color.limegreen, Color.turquoise, Color.turquoise, Color.red, Color.red, Color.purple, Color.purple, Color.gold, Color.gold, Color.gold]
var nameArray = ["MP5", "UMP 45", "P90", "SPAS12", "XM1014", "M4A1", "AK 12", "M60", "M249", "BARRETT 50", "AWP", "INTERVENTION"]
var priceArray = [1500, 1600, 2000, 2500, 3000, 3000, 3100, 5500, 6000, 5000, 5000, 5500]
var scaleArray = PoolVector2Array([Vector2(1,1), Vector2(.75,.75), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(.9,.9), Vector2(.9,.9), Vector2(1,1), Vector2(.75,.75), Vector2(.75,.75)])

var canBuy = false
var enoughMoney = false
var Selected_Weapon2 
onready var gunscript = get_node("../../Player/body/chest/torso/gun")
signal play_sound(library)

export(int, "MP5", "UMP45", "P90", "SPAS12", "XM1014", "M4A1", "AK12", "M60", "M249", "BARRETT50", "AWP", "INTERVENTION") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
		for w in range(gunscript.weapon_slots.size()):
			if gunscript.weapon_slots[w] == -1:
				gunscript.current_weapon = w
				gunscript.weapon_slots[w] = Selected_Weapon
				break
		
		for c in range(gunscript.weapon_slots.size()):
			if gunscript.current_weapon == c:
				gunscript.weapon_slots[c] = Selected_Weapon
				break
			
		gunscript.set_gun(Selected_Weapon)
		emit_signal("play_sound", "buy")
		
		# The price of the weapon minus the score of the player
		for i in spriteArray.size():
			if Selected_Weapon == i:
				Global.Score -= priceArray[i]
	
	elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
		emit_signal("play_sound", "not_enough_money")
	
	# checks if the player has enough money/score
	if Global.Score >= priceArray[Selected_Weapon]:
		enoughMoney = true
	else:
		enoughMoney = false

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false

#Dynamically sets the label with the correct values and also sets the sprites to the right one
func _ready():
	$Sprite.set_texture(spriteArray[Selected_Weapon])
	$Sprite.scale=scaleArray[Selected_Weapon]
	$Light2D.color = colorArray[Selected_Weapon]
	$WeaponLabelName.text = nameArray[Selected_Weapon]
	$WeaponLabelPrice.text = str(priceArray[Selected_Weapon])
