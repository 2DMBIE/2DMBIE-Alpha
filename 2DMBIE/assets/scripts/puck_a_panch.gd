extends Node2D

var spriteMP5 = preload("res://assets/sprites/guns/mp5_puck_a_panch.png")
var spriteUMP45 = preload("res://assets/sprites/guns/UMP45_puck_a_panch.png")
var spriteP90 = preload("res://assets/sprites/guns/p90_puck_a_panch.png")

#shotgun
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12_puck_a_panch.png")
var spriteXM1014 = preload("res://assets/sprites/guns/XM1014_puck_a_panch.png")

#assault rifle
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1_puck_a_panch.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12_puck_a_panch.png")

#LMG
var spriteM60 = preload("res://assets/sprites/guns/M60_puck_a_panch.png")
var spriteM249 = preload("res://assets/sprites/guns/M249_puck_a_panch.png")

#sniper
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50_puck_a_panch.png")
var spriteAWP = preload("res://assets/sprites/guns/AWP_puck_a_panch.png")
var spriteIntervention = preload("res://assets/sprites/guns/Intervention_puck_a_panch.png")

var spriteArray = [spriteMP5, spriteUMP45, spriteP90, spriteSPAS12, spriteXM1014, spriteM4A1, spriteAK12, spriteM60, spriteM249, spriteBARRETT50, spriteAWP, spriteIntervention]
var colorArray = [Color.limegreen, Color.limegreen, Color.limegreen, Color.turquoise, Color.turquoise, Color.red, Color.red, Color.purple, Color.purple, Color.gold, Color.gold, Color.gold]
var scaleArray = PoolVector2Array([Vector2(.8,.8), Vector2(.6,.6), Vector2(.8,.8), Vector2(.8,.8), Vector2(.8,.8), Vector2(.7,.7), Vector2(.8,.8), Vector2(.45,.45), Vector2(.45,.45), Vector2(.65,.65), Vector2(.45,.45), Vector2(.45,.45)])

var weaponPap = [MP5_pap.new(), UMP45_pap.new(), P90_pap.new(), SPAS12_pap.new(),XM1014_pap.new(), M4A1_pap.new(), AK12_pap.new(), M60_pap.new(), M249_pap.new(), BARRETT50_pap.new(), AWP_pap.new(), INTERVENTION_pap.new()]

var canBuy = false
var enoughMoney = false
var GotGun = true
var CycleEnded = false
onready var timer = get_node("Timer_buy_wait_time")
onready var gunscript = get_node("../../Player/body/chest/torso/gun")
onready var animatedsprite = get_node("AnimatedSprite")

signal play_sound(library)

#export(int, "MP5", "UMP45", "P90", "SPAS12", "XM1014", "M4A1", "AK12", "M60", "M249", "BARRETT50", "AWP", "INTERVENTION") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney and GotGun:
#		print(gunscript.guns[gunscript.current_gun_index].name, " | ", weaponPap[gunscript.current_gun_index].name)
		timer.set_wait_time(13.11)
		timer.start()
		GotGun = false

		emit_signal("play_sound", "buy")
		Global.Score -= int(5000)
#	print(gunscript.guns[gunscript.current_gun_index].name)
#	print(weaponPap[0].name)

	elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
		emit_signal("play_sound", "not_enough_money")
		
	if Input.is_action_just_pressed("use") and canBuy and CycleEnded:
		gunscript.guns[gunscript.current_gun_index] = weaponPap[gunscript.current_gun_index]
		gunscript.set_gun(gunscript.current_gun_index)
		$Sprite.hide()
		$Light2D2.hide()
		GotGun = true
		CycleEnded = false

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
	
	if Global.Score >= int(5000):
		enoughMoney = true
	else:
		enoughMoney = false

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false


func _on_Timer_buy_wait_time_timeout():
	timer.stop()
#	animatedsprite.set_frame(0)
#	animatedsprite.stop()
	$Sprite.set_texture(spriteArray[gunscript.current_gun_index])
	$Sprite.scale=scaleArray[gunscript.current_gun_index]
	$Light2D2.color = colorArray[gunscript.current_gun_index]
	$Sprite.show()
	$Light2D2.show()
	CycleEnded = true
