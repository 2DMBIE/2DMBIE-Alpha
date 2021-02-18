extends StaticBody2D

signal health_updated(health)
signal killed()

export (float) var maxHealth = 500

onready var health = maxHealth setget _set_health


func kill():
	queue_free()
	
func _damage(amount):
	_set_health(health - amount)

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
			emit_signal("killed")
			
