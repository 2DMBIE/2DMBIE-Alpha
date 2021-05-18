class_name Perk

var name: String

func _init(newName = 'General Perk'):
	name = newName
	
func printPerkName():
	print('Perk is ' + name)
