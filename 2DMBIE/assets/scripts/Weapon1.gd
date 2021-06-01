extends Control

var gunscript

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("playersLoaded", self, "_on_playersLoaded")

func _process(_delta):
	if gunscript != null:
		$Weapon1/Sprite.texture = gunscript.guns[gunscript.weapon_slots[0]].texture
		$Weapon2/Sprite.texture = gunscript.guns[gunscript.weapon_slots[1]].texture
		
		if gunscript.weapon_slots[1] == -1:
			$Weapon2.visible = false
		else:
			$Weapon2.visible = true

func _on_playersLoaded():
	gunscript = get_node("/root/Lobby/Players/"+str(gamestate.player_id)+"/body/chest/torso/gun")
