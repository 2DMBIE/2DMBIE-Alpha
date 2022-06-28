extends RigidBody2D

var timer = Timer.new()

func _ready():	
	if Global.maia:
		timer.set_wait_time(10)
	else:
		timer.set_wait_time(3)
	timer.set_one_shot(true)
	timer.connect("timeout", self, "_on_timer_timeout")
	
	add_child(timer)
	timer.start()

func _physics_process(_delta):
	if $Sprite.modulate.a == 0:
		queue_free()

func _on_timer_timeout():
	timer.set_wait_time(.1)
	timer.start()
	$Sprite.modulate.a -= 0.1
	
	if $Sprite.modulate.a <= 0:
		queue_free()
	
