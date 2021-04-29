extends Node2D

var canBuy = false

func _physics_process(delta):
	if Input.is_action_just_pressed("use") and canBuy == true:
		get_node("../Player/body/chest/torso/gun").set_gun(2)
		
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
