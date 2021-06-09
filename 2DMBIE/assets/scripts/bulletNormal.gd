extends KinematicBody2D

var damage = 100
var speed = 750
var direction := Vector2.ZERO
var enemy_penetration = 0
var bullet_penetration = 2
var bulletEnterPos
var bulletCalc = false
var velocity
var halfRadius

func _physics_process(delta):
	if direction != Vector2.ZERO:
		velocity = direction * speed * delta
		global_position += velocity
	
#	if bulletCalc:
#		if (velocity.x > 0 and self.position.x > bulletEnterPos - halfRadius) or (velocity.x < 0 and self.position.x < bulletEnterPos + halfRadius):
#			self.visible = false

func _on_bullet_body_entered(body):
	if body.is_in_group("enemies"):
		body.Hurt(damage)
		Global.Score += 10
		enemy_penetration += 1
		bulletEnterPos = position.x
		if enemy_penetration >= bullet_penetration:
			self.visible = false
#			halfRadius = body.get_node("CollisionShape2D").shape.radius * 10
#			bulletCalc = true
#	if body.is_in_group("enemyHeads"):
#		pass
	else:
		queue_free()

func set_direction(directionx: Vector2):
	self.direction = directionx

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_bullet_body_exited(body):
	if body.is_in_group("enemies"):
		if enemy_penetration >= bullet_penetration:
			queue_free()
