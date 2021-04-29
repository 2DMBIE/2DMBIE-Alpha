extends Area2D

var damage = 100
var speed = 750
var direction := Vector2.ZERO
var enemy_penetration = 0
var bullet_penetration = 2

func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed * delta
		global_position += velocity

func _on_bullet_body_entered(body):	
	if body.is_in_group("enemies"):
		body.Hurt(damage)
	else:
		queue_free()

func set_direction(directionx: Vector2):
	self.direction = directionx

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_bullet_body_exited(body):
	if body.is_in_group("enemies"):
		enemy_penetration += 1
		if enemy_penetration >= bullet_penetration:
			queue_free()
