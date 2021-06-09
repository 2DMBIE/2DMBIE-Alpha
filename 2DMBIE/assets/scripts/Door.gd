extends Node2D

var priceArray = [500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7500] # sync this
var price 
var can_buy = false
signal play_sound(library)

func _physics_process(_delta):
	if Input.is_action_just_pressed("use") && can_buy == true and not Global.Score >= price :
		emit_signal("play_sound", "not_enough_money")
	elif Input.is_action_just_pressed("use") && Global.Score >= price && can_buy == true:
		buy_door()
		Global.unlocked_doors += 1
		can_buy = false
	
	if !name == "Secret":
		price = priceArray[Global.unlocked_doors]
	else:
		price = 10000
	
func _on_doorareaRight_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelRight.text = str(int(price))
		$PricelabelRight.visible = true
		can_buy = true

func _on_doorareaRight_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelRight.visible = false
		can_buy = false

func buy_door():
	rpc("remove_door")
	emit_signal("play_sound", "buy")
	Global.Score -= price

remotesync func remove_door():
	$doorareaRight/right.disabled = true
	$doorareaLeft/left.disabled = true
	$door.disabled = true
	$doorSprite.position.y -= 160

func _on_doorareaLeft_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelLeft.text = str(int(price))
		$PricelabelLeft.visible = true
		can_buy = true

func _on_doorareaLeft_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelLeft.visible = false
		can_buy = false
