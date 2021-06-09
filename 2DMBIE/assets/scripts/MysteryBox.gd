extends Node2D

var weapons = [MP5.new(), UMP45.new(), P90.new(), SPAS12.new(),XM1014.new(), M4A1.new(), AK12.new(), M60.new(), M249.new(), BARRETT50.new(), AWP.new(), INTERVENTION.new()]

var canBuy = false
var enoughMoney = false
var rng = RandomNumberGenerator.new()
onready var gunscript = get_node("../../Player/body/chest/torso/gun")

signal play_sound(library)

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
		rng.randomize()
		var randomweapon = rng.randi_range(0,11)
		
		for w in range(gunscript.weapon_slots.size()):
			if gunscript.weapon_slots[w] == -1:
				gunscript.current_weapon = w
				gunscript.weapon_slots[w] = randomweapon
				break
		
		for c in range(gunscript.weapon_slots.size()):
			if gunscript.current_weapon == c:
				gunscript.weapon_slots[c] = randomweapon
				break
		gunscript.set_gun(randomweapon)
		
		emit_signal("play_sound", "buy")
		Global.Score -= int(1000)
	elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
		emit_signal("play_sound", "not_enough_money")

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
	
	if Global.Score >= int(1000):
		enoughMoney = true
	else:
		enoughMoney = false

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
