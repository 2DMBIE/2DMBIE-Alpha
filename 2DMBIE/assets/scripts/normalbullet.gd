extends Area2D

var damage = 100
var speed = 750
var direction := Vector2.ZERO
var enemy_penetration = 0
var bullet_penetration = 2
var bulletEnterPos
var bulletCalc = false
var velocity
var halfRadius

var timer = Timer.new()

func _ready():
	timer.one_shot = true
	timer.wait_time = 8
	timer.connect("timeout", self, "_self_destruct")
	add_child(timer)
	timer.start()

func _physics_process(delta):
	if direction != Vector2.ZERO:
		velocity = direction * speed * delta
		global_position += velocity

func _on_bullet_body_entered(body):
	if body.is_in_group("enemies"):
		if is_network_master():
			body.rpc("hurt", damage, get_network_master())
			Global.Score += 10
		enemy_penetration += 1
		bulletEnterPos = position.x
		if enemy_penetration >= bullet_penetration:
			self.visible = false
	else:
		_self_destruct()

func set_direction(directionx: Vector2):
	self.direction = directionx

func _on_bullet_body_exited(body):
	if body.is_in_group("enemies"):
		if enemy_penetration >= bullet_penetration:
			_self_destruct()

func _self_destruct():
#	for p_id in gamestate.players:
#		rpc_id(p_id, "self_destruct_remote")
	queue_free()

remote func self_destruct_remote():
	queue_free()
