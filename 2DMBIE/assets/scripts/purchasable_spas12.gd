extends Node2D

var canBuy = false
onready var gunscript = get_node("../Player/body/chest/torso/gun")

func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy == true:
		if gunscript.weapon_slots[1] == -1:
			gunscript.current_weapon = 1
			gunscript.weapon_slots[1] = 1
		elif gunscript.current_weapon == 0:
			gunscript.weapon_slots[0] = 1
		elif gunscript.current_weapon == 1:
			gunscript.weapon_slots[1] = 1
			
		gunscript.set_gun(1)

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
