extends Label

func _on_Player_ammoUpdate(_ammo, _maxClipammo, totalAmmo):
	text = str(totalAmmo)
