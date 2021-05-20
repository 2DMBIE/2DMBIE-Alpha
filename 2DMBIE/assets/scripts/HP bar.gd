extends TextureProgress

func _ready():
	pass

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
