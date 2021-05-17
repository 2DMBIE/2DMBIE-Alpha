extends Node2D

var canBuy = false
onready var gunscript = get_node("../Player/body/chest/torso/gun")

export var Selected_Weapon = 0

func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy:
		for i in range(gunscript.weapon_slots.size()):
			if gunscript.weapon_slots[i] == -1:
				gunscript.current_weapon = (i)
				gunscript.weapon_slots[i] = Selected_Weapon
				return
			
			elif gunscript.current_weapon == i:
				gunscript.weapon_slots[i] = Selected_Weapon
		
		gunscript.set_gun(Selected_Weapon)

func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
		print("player entered the area")
		print(canBuy)

func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
		print("player exited the area")
		print(canBuy)
