class_name Bullet

var _scene: PackedScene
var _damage: float
var _speed: float
var _penetration: int

# Class Constructor
func _init(bdmg = float(500), bspeed = float(750), path = "", bpen = int(2)):
	_damage = bdmg
	_speed = bspeed
	_penetration = bpen 
	#var plBullet := preload (float(500), float(750), "res://assets/scenes/bullet.tscn")
	if not path.empty():
		_scene = load(path)
		
func getBullet():
	var instance = _scene.instance()
	instance.get_node(".").speed = _speed
	instance.get_node(".").damage = _damage
	instance.get_node(".").bullet_penetration = _penetration
	return instance
