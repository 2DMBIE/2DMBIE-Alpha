#extends Node
#
#class_name Perk
#
#var perk_name: String
#var price: String
#var texture: Texture
#
#func _init(perkName = 'General Perk', perkPrice = '0', path = ""):
#	perk_name = perkName
#	price = perkPrice
#	if not path.empty():
#		texture = load(path)
#
#func activate():
#	pass
#
#func deactivate():
#	pass
