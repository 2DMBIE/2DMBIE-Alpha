extends Perk

class_name MovementPerk

signal on_movementperk_event(received)

func _init():
	name = "MovementPerk"
	price = "4000"
	texture = load("res://assets/sprites/perks/movement_perk.png")

func activate():
	emit_signal("on_movementperk_event", true)

func deactivate():
	emit_signal("on_movementperk_event", false)
