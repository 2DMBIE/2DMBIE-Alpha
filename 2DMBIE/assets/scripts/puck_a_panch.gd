extends Node2D

#smg
var spriteMP5_pap = preload("res://assets/sprites/guns/mp5.png")
var spriteUMP45_pap = preload("res://assets/sprites/guns/UMP45.png")
var spriteP90_pap = preload("res://assets/sprites/guns/p90.png")

#shotgun
var spriteSPAS12_pap = preload("res://assets/sprites/guns/spas12.png")
var spriteXM1014_pap = preload("res://assets/sprites/guns/XM1014.png")

#assault rifle
var spriteM4A1_pap = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12_pap = preload("res://assets/sprites/guns/ak12.png")

#LMG
var spriteM60_pap = preload("res://assets/sprites/guns/M60.png")
var spriteM249_pap = preload("res://assets/sprites/guns/M249.png")

#sniper
var spriteBARRETT50_pap = preload("res://assets/sprites/guns/barrett50.png")
var spriteAWP_pap = preload("res://assets/sprites/guns/AWP.png")
var spriteIntervention_pap = preload("res://assets/sprites/guns/Intervention.png")

var spriteArray = [spriteMP5_pap, spriteUMP45_pap, spriteP90_pap, spriteSPAS12_pap, spriteXM1014_pap, spriteM4A1_pap, spriteAK12_pap, spriteM60_pap, spriteM249_pap, spriteBARRETT50_pap, spriteAWP_pap, spriteIntervention_pap]
var colorArray = [Color.limegreen, Color.limegreen, Color.limegreen, Color.turquoise, Color.turquoise, Color.red, Color.red, Color.purple, Color.purple, Color.gold, Color.gold, Color.gold]
var nameArray = ["MP5", "UMP 45", "P90", "SPAS12", "XM1014", "M4A1", "AK 12", "M60", "M249", "BARRETT 50", "AWP", "INTERVENTION"]
var priceArray = [1500, 1600, 2000, 2500, 3000, 3000, 3100, 5500, 6000, 5000, 5000, 5500]
var scaleArray = PoolVector2Array([Vector2(1,1), Vector2(.75,.75), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(1,1), Vector2(.75,.75), Vector2(1,1)])

var weaponPap = [MP5_pap.new(), UMP45_pap.new(), P90_pap.new(), SPAS12_pap.new(),XM1014_pap.new(), M4A1_pap.new(), AK12_pap.new(), M60_pap.new(), M249_pap.new(), BARRETT50_pap.new(), AWP_pap.new(), INTERVENTION_pap.new()]

var canBuy = false
var enoughMoney = false
var Selected_Weapon = 0
onready var gunscript = get_node("../../Player/body/chest/torso/gun")
signal play_sound(library)

#export(int, "MP5", "UMP45", "P90", "SPAS12", "XM1014", "M4A1", "AK12", "M60", "M249", "BARRETT50", "AWP", "INTERVENTION") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy:
		print(gunscript.guns[gunscript.current_gun_index].name, " | ", weaponPap[gunscript.current_gun_index].name)
		gunscript.guns[gunscript.current_gun_index] = weaponPap[gunscript.current_gun_index]
		gunscript.set_gun(gunscript.current_gun_index)
	print(gunscript.guns[gunscript.current_gun_index].name)
#	print(weaponPap[0].name)

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false

var testArray = ["A", "B"]
func _ready():
	print(testArray)
	testArray[0] = "C"
	print(testArray)
