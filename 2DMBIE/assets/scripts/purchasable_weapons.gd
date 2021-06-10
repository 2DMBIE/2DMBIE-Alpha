extends Node2D

var spriteMP5 = preload("res://assets/sprites/guns/mp5.png")
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12.png")
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12outline.png")
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50.png")
var spriteArray = [spriteMP5, spriteSPAS12, spriteM4A1, spriteAK12, spriteBARRETT50]
var colorArray = [Color.limegreen, Color.turquoise, Color.gold, Color.red, Color.pink]
var nameArray = ["MP5", "SPAS12", "M4A1", "AK12", "BARRETT50"]
var priceArray = [1500, 2500, 3000, 3100, 4000]

var canBuy = false
var enoughMoney = false
var gunscript
signal play_sound(library)

var id = 0

export(int, "MP5", "SPAS12", "M4A1", "AK12", "BARRETT50") var Selected_Weapon = 0 

#the player can buy a weapon ans sets it to the correct slot
func _physics_process(_delta):
	if gunscript != null:
		if int(id) == get_tree().get_network_unique_id():
			if Input.is_action_just_pressed("use") and canBuy and enoughMoney:
				for w in range(gunscript.weapon_slots.size()):
					if gunscript.weapon_slots[w] == -1:
						gunscript.current_weapon = w
						gunscript.weapon_slots[w] = Selected_Weapon
						break
				
				for c in range(gunscript.weapon_slots.size()):
					if gunscript.current_weapon == c:
						gunscript.weapon_slots[c] = Selected_Weapon
						break
					
				gunscript.set_gun(Selected_Weapon)
				emit_signal("play_sound", "buy")
				
				# The price of the weapon minus the score of the player
				for i in spriteArray.size():
					if Selected_Weapon == i:
						Global.Score -= priceArray[i]
			
			elif Input.is_action_just_pressed("use") and canBuy and not enoughMoney:
				emit_signal("play_sound", "not_enough_money")
			
			# checks if the player has enough money/score
			if Global.Score >= priceArray[Selected_Weapon]:
				enoughMoney = true
			else:
				enoughMoney = false

#checks if the player is in the buy area
func _on_buyarea_body_entered(body):
	if body.is_in_group("player"):
		canBuy = true
		id = body.name

#checks if the player is out of the buy area
func _on_buyarea_body_exited(body):
	if body.is_in_group("player"):
		canBuy = false
		id = 0

#Dynamically sets the label with the correct values and also sets the sprites to the right one
func _ready():
	$Sprite.set_texture(spriteArray[Selected_Weapon])
	$Light2D.color = colorArray[Selected_Weapon]
	$WeaponLabelName.text = nameArray[Selected_Weapon]
	$WeaponLabelPrice.text = str(priceArray[Selected_Weapon])
	
	# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "on_player_loaded")

func on_player_loaded():
	var _path = ""
	if get_tree().get_root().has_node("/root/World/Players"):
		_path = "/root/World/Players/"
	else:
		_path = "/root/Lobby/Players/"
	gunscript = get_tree().root.get_node(_path + str(gamestate.player_id) + "/body/chest/torso/gun")
	#gunscript = get_node("/root/Lobby/Players/"+str(gamestate.player_id)+)
