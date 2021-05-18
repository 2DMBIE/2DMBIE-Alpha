class_name Perk

var name: String
var price: String
var texture: Texture

func _init(perkName = 'General Perk', perkPrice = '0', path = ""):
	name = perkName
	price = perkPrice
	if not path.empty():
		texture = load(path)

func activate():
	print("707")
	
func deactivate():
	pass
