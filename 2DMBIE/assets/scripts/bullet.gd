extends Area2D

export (float) var damage = 300
var speed = 750
var direction := Vector2.ZERO
var bulletpenatration = 2
var enemyPenetration = 0

func _physics_process(delta):
	if direction != Vector2.ZERO:
		var velocity = direction * speed * delta
		global_position += velocity

func _on_bullet_body_entered(body):	
	var enemyPenetration = 0
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
#		visible = false
		enemyPenetration += 1
		if enemyPenetration >= bulletpenatration:
			queue_free()
