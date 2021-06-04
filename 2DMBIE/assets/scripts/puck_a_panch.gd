extends Node2D

var weaponPap = [MP5_pap.new(), UMP45_pap.new(), P90_pap.new(), SPAS12_pap.new(),XM1014_pap.new(), M4A1_pap.new(), AK12_pap.new(), M60_pap.new(), M249_pap.new(), BARRETT50_pap.new(), AWP_pap.new(), INTERVENTION_pap.new()]

var canBuy = false
var enoughMoney = false
var Selected_Weapon = 0
onready var gunscript = get_node("../../Player/body/chest/torso/gun")
signal play_sound(library)

#export(int, "MP5", "UMP45", "P90", "SPAS12", "XM1014", "M4A1", "AK12", "M60", "M249", "BARRETT50", "AWP", "INTERVENTION") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
#		print(gunscript.guns[gunscript.current_gun_index].name, " | ", weaponPap[gunscript.current_gun_index].name)
		gunscript.guns[gunscript.current_gun_index] = weaponPap[gunscript.current_gun_index]
		gunscript.set_gun(gunscript.current_gun_index)
		emit_signal("play_sound", "buy")
		Global.Score -= int(5000)
#	print(gunscript.guns[gunscript.current_gun_index].name)
#	print(weaponPap[0].name)
	elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
		emit_signal("play_sound", "not_enough_money")

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
