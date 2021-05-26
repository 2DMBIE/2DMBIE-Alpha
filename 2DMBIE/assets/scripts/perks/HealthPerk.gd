#extends Perk
#
#class_name HealthPerk
#
#signal on_healthperk_event(received)
#
#func _init():
#	name = "HealthPerk"
#	price = "3500"
#	texture = load("res://assets/sprites/perks/health_perk.png")
#	# Absolute Node Path
#	# Variable
#	# New value
#func activate():
#	emit_signal("on_healthperk_event", true)
#
#func deactivate():
#	emit_signal("on_healthperk_event", false)
