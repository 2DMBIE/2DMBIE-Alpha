extends Node2D

var spriteMP5 = preload("res://player/weapons/mp5/mp5.png")
var spriteUMP45 = preload("res://player/weapons/ump45/ump45.png")
var spriteP90 = preload("res://player/weapons/p90/p90.png")

#shotgun
var spriteSPAS12 = preload("res://player/weapons/spas12/spas12.png")
var spriteXM1014 = preload("res://player/weapons/xm1014/xm1014.png")

#assault rifle
var spriteM4A1 = preload("res://player/weapons/m4a1/m4a1.png")
var spriteAK12 = preload("res://player/weapons/ak12/ak12.png")

#LMG
var spriteM60 = preload("res://player/weapons/m60/m60.png")
var spriteM249 = preload("res://player/weapons/m249/m249.png")

#sniper
var spriteBARRETT50 = preload("res://player/weapons/barrett50/barrett50.png")
var spriteAWP = preload("res://player/weapons/awp/awp.png")
var spriteIntervention = preload("res://player/weapons/intervention/intervention.png")

var spriteArray = [spriteMP5, spriteUMP45, spriteP90, spriteSPAS12, spriteXM1014, spriteM4A1, spriteAK12, spriteM60, spriteM249, spriteBARRETT50, spriteAWP, spriteIntervention]
var colorArray = [Color.limegreen, Color.limegreen, Color.limegreen, Color.turquoise, Color.turquoise, Color.red, Color.red, Color.purple, Color.purple, Color.gold, Color.gold, Color.gold]
var scaleArray = PoolVector2Array([Vector2(.8,.8), Vector2(.6,.6), Vector2(.8,.8), Vector2(.8,.8), Vector2(.8,.8), Vector2(.7,.7), Vector2(.8,.8), Vector2(.45,.45), Vector2(.45,.45), Vector2(.65,.65), Vector2(.45,.45), Vector2(.45,.45)])

var weapons = [MP5.new(), UMP45.new(), P90.new(), SPAS12.new(), XM1014.new(), M4A1.new(), AK12.new(), M60.new(), M249.new(), BARRETT50.new(), AWP.new(), INTERVENTION.new()]

var canBuy = false
var enoughMoney = false
var GotGun = true
var CycleEnded = false
var rng = RandomNumberGenerator.new()
var randomweapon

onready var timer = get_node("Timer_buy_wait_time")
onready var gunscript = get_node("../../Player/body/chest/torso/gun")
onready var animatedsprite = get_node("AnimatedSpriteCycle")
onready var animatedspriteidle = get_node("AnimatedSpriteIdle")

signal play_sound(library)

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	
	
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney and GotGun:
		
		emit_signal("play_sound", "buy")
		timer.set_wait_time(12.09)
		timer.start()
		animatedspriteidle.hide()
		animatedsprite.show()
		animatedsprite.play()
		GotGun = false
		
		Global.Score -= int(3000)
		
	elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
		emit_signal("play_sound", "not_enough_money")
		
	if Input.is_action_just_pressed("use") and canBuy and CycleEnded:
			
		for w in range(gunscript.weapon_slots.size()):
			if gunscript.weapon_slots[w] == -1:
				gunscript.current_weapon = w
				gunscript.weapon_slots[w] = randomweapon
				break
			
		for c in range(gunscript.weapon_slots.size()):
			if gunscript.current_weapon == c:
				gunscript.weapon_slots[c] = randomweapon
				break
				
		animatedspriteidle.show()
		gunscript.set_gun(randomweapon)
		$Sprite.hide()
		$Light2D2.hide()
		GotGun = true
		CycleEnded = false

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
	
	if Global.Score >= int(3000):
		enoughMoney = true
	else:
		enoughMoney = false

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false


func _on_Timer_buy_wait_time_timeout():
	rng.randomize()
	randomweapon = rng.randi_range(0,11)
	timer.stop()
	animatedsprite.stop()
	animatedsprite.set_frame(0)
	$Sprite.set_texture(spriteArray[randomweapon])
	$Sprite.scale=scaleArray[randomweapon]
	$Light2D2.color = colorArray[randomweapon]
	$Sprite.show()
	$Light2D2.show()
	CycleEnded = true
	
