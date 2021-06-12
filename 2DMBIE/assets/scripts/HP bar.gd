extends TextureProgress

func _ready():
	# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "_on_player_loaded")	

func _on_player_loaded():
	if get_tree().root.has_node("/root/World"):
	# warning-ignore:return_value_discarded
		get_node("/root/World/Players/" + str(gamestate.player_id)).connect("health_updated", self, "_on_Player_health_updated")

func _on_Player_health_updated(health, maxHealth):
	max_value = maxHealth
	value = health
	var percentageHP = int((float(health) / maxHealth * 100))
	if percentageHP >= 70:
		set_tint_progress("14e114")
	elif percentageHP <= 70 and percentageHP >= 30:
		set_tint_progress("e1be32")
	else:
		set_tint_progress("e11e1e")
