extends Control

onready var gunscript = get_node("../../../Player/body/chest/torso/gun")

func _process(_delta):
	$Weapon1/Sprite.texture = gunscript.guns[gunscript.weapon_slots[0]].texture
	$Weapon2/Sprite.texture = gunscript.guns[gunscript.weapon_slots[1]].texture

	if gunscript.weapon_slots[1] == -1:
		$Weapon2.visible = false
	else:
		$Weapon2.visible = true

	if gunscript.weapon_slots[0] == -1:
		$Weapon1.visible = false
	else:
		$Weapon1.visible = true
