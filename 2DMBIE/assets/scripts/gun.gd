class_name Gun

# Member Variables
var name: String
var offset: Vector2
var scale: Vector2
var texture: Texture
var bulletpoint: Vector2

#Gunshake Ex. Shotgun: Heavy, m4a1: 

# Class Constructor
func _init(gun_name = "gun", gun_offset = Vector2(0,0), gun_scale = Vector2(1,1), path = "", bp = Vector2(0,0)):
	name = gun_name
	offset = gun_offset
	scale = gun_scale
	texture = load(path)
	bulletpoint = bp

func simpleFunc():
	print("My name is ", name)
	print(typeof(name)) # Shows the Data Type
