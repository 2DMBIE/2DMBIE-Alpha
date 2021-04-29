extends Node2D

var canBuy = false
onready var gunscript = get_node("../Player/body/chest/torso/gun")

func _physics_process(delta):
	if Input.is_action_just_pressed("use") and canBuy == true:
		if gunscript.weapon_slot_2 == -1:
			gunscript.current_weapon = 1
			gunscript.weapon_slot_2 = 1
		elif gunscript.current_weapon == 0:
			gunscript.weapon_slot_1 = 1
		elif gunscript.current_weapon == 1:
			gunscript.weapon_slot_2 = 1
			
		gunscript.set_gun(1)
		
		pass

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
