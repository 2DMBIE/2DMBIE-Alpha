extends Node2D

var spriteMP5 = preload("res://assets/sprites/guns/mp5.png")
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12.png")
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12.png")
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50.png")
var spriteArray = [spriteMP5, spriteSPAS12, spriteM4A1, spriteAK12, spriteBARRETT50]
var colorArray = [Color.limegreen, Color.turquoise, Color.gold, Color.orange, Color.pink]

var canBuy = false
onready var gunscript = get_node("../Player/body/chest/torso/gun")

export(int, "MP5", "SPAS12", "M4A1", "AK12", "BARRETT50") var Selected_Weapon = 0 

func _physics_process(_delta):
	if Input.is_action_just_pressed("use") and canBuy:
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

func _ready():
	for i in spriteArray.size():
		if Selected_Weapon == i:
			$Sprite.set_texture(spriteArray[i])
			$Light2D.color = colorArray[i]
