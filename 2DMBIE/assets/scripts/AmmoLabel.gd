extends Label



func _on_Player_ammoUpdate(ammo, maxClipammo, _totalAmmo):
	text = "(" + str(ammo) + '/' + str(maxClipammo) + ")"
