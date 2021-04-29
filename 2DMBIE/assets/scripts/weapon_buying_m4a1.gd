extends Sprite

var canBuy = false

func _physics_process(delta):
	if Input.is_action_just_pressed("use") and canBuy == true:
		#can buy weapon
		
		pass
