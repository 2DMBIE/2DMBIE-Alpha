extends StaticBody2D

signal health_updated(health)

export (float) var maxHealth = 500


onready var health = maxHealth setget _set_health

func Hurt(damage):
	_set_health(health - damage)
	print(health)

func kill():
	queue_free()

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()


