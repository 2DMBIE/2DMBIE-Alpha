extends Control

var spriteMP5 = preload("res://assets/sprites/guns/mp5.png")
var spriteSPAS12 = preload("res://assets/sprites/guns/spas12.png")
var spriteM4A1 = preload("res://assets/sprites/guns/m4a1.png")
var spriteAK12 = preload("res://assets/sprites/guns/ak12.png")
var spriteBARRETT50 = preload("res://assets/sprites/guns/barrett50.png")
var spriteArray = [spriteMP5, spriteSPAS12, spriteM4A1, spriteAK12, spriteBARRETT50]

onready var gunscript = get_node("../../../Player/body/chest/torso/gun")

func _physics_process(_delta):
	$Sprite.texture = gunscript.guns[gunscript.weapon_slots[0]].texture


	
