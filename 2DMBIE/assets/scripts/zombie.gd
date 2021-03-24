extends KinematicBody2D


const MAX_WALK_SPEED = 20 #old 110 
const WALK_ACCELERATION = 10 #old 20

const MAX_WALK_SPEED_STEP = 90 #old 110 
const WALK_ACCELERATION_STEP = 80 #old 20

const GRAVITY = 20
var motion = Vector2()
var zombiestep = false

const UP = Vector2(0, -1)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !is_on_floor():
		$AnimationPlayer.play("jump")
	else:
		$AnimationPlayer.play("walk")
	
	if zombiestep:
		motion.y += GRAVITY
	
		motion.x += WALK_ACCELERATION_STEP
		motion.x = min(motion.x, MAX_WALK_SPEED_STEP)

		if is_on_floor():
			motion.x = lerp(motion.x, 0, 0.3)
		else:
			motion.x = lerp(motion.x, 0, 0.05)
		motion = move_and_slide(motion, UP)
	else: 
		motion.y += GRAVITY
	
		motion.x += WALK_ACCELERATION
		motion.x = min(motion.x, MAX_WALK_SPEED)

		if is_on_floor():
			motion.x = lerp(motion.x, 0, 0.3)
		else:
			motion.x = lerp(motion.x, 0, 0.05)
		motion = move_and_slide(motion, UP)
		
func togglestep():
	zombiestep = !zombiestep

signal health_updated(health)

export (float) var maxHealth = 500
export (float) var enemyDamage = 300

onready var health = maxHealth setget _set_health

func Hurt(damage):
	_set_health(health - damage)

func kill():
	Global.Score()
	queue_free()

func _set_health(value):
	var prevHealth = health
	health = clamp(value, 0, maxHealth)
	if health != prevHealth:
		emit_signal("health_updated", health)
		if health == 0:
			kill()
