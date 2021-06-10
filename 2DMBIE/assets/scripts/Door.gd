extends Node2D

const prices = [500, 750, 1000, 1250, 1500, 2000, 2500, 3000, 4000, 5000, 6000, 7500] # sync this
var can_buy = false
var id = 0
signal play_sound(library)

func _physics_process(_delta):
	if int(id) == get_tree().get_network_unique_id():
		if Input.is_action_just_pressed("use") and can_buy == true and not Global.Score >= get_price():
			emit_signal("play_sound", "not_enough_money")
		elif Input.is_action_just_pressed("use") and Global.Score >= get_price() and can_buy == true:
			buy_door()
			can_buy = false

func _on_doorareaRight_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelRight.text = str(get_price())
		$PricelabelRight.visible = true
		can_buy = true
		id = body.name
	else:
		$PricelabelRight.visible = false

func _on_doorareaRight_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelRight.visible = false
		can_buy = false
		id = 0

func _on_doorareaLeft_body_entered(body):
	if body.is_in_group("player"):
		$PricelabelLeft.text = str(get_price())
		$PricelabelLeft.visible = true
		can_buy = true
		id = body.name
	else:
		$PricelabelLeft.visible = false

func _on_doorareaLeft_body_exited(body):
	if body.is_in_group("player"):
		$PricelabelLeft.visible = false
		can_buy = false
		id = 0

func buy_door():
	Global.Score -= get_price()
	rpc("remove_door")
	emit_signal("play_sound", "buy")

remotesync func remove_door():
	$PricelabelLeft.visible = false
	$PricelabelRight.visible = false
	$doorareaRight/right.disabled = true
	$doorareaLeft/left.disabled = true
	$door.disabled = true
	$doorSprite.position.y -= 160
	refresh_door_prices()

func get_total_unlocked_doors() -> int:
	var _i = 0
	for door in get_parent().get_children():
		if door.get_node("door").disabled == true:
			_i = _i+1
	return _i

func get_price() -> int:
	if name == "Secret":
		return 10000
	else:
		return prices[get_total_unlocked_doors()]

func getID() -> int:
	return int(id)

func get_name() -> String:
	return str(name)

func refresh_door_prices():
	for door in get_parent().get_children():
		if door.getID() == int(0): 
			door.get_node("PricelabelRight").visible = false
			door.get_node("PricelabelLeft").visible = false
		if door.get_name() != "Secret": # The Secret door price must be unaffected since the price is always 10000
			door.get_node("PricelabelRight").text = str(prices[get_total_unlocked_doors()])	
			door.get_node("PricelabelLeft").text = str(prices[get_total_unlocked_doors()])
