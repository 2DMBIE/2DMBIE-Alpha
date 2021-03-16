extends KinematicBody2D


const MAX_WALK_SPEED = 20 #old 110 
const WALK_ACCELERATION = 10 #old 20
const GRAVITY = 20
var motion = Vector2()
var zombiestep = false

const UP = Vector2(0, -1)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$AnimationPlayer.play("walk")
	if Input.is_action_just_pressed("sprint"):
		zombiestep = !zombiestep

	var friction = false
	motion.y += GRAVITY
	
	motion.x += WALK_ACCELERATION
	motion.x = min(motion.x, MAX_WALK_SPEED)

	if is_on_floor():
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
	motion = move_and_slide(motion, UP)

		
func step():
	var friction = false
	motion.y += GRAVITY
	
	motion.x += 40
	motion.x = min(motion.x,90)

	if is_on_floor():
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.3)
	else:
		if friction == true:
			motion.x = lerp(motion.x, 0, 0.05)
	motion = move_and_slide(motion, UP)
	#print("helloo")

func togglestep():
	zombiestep = !zombiestep

signal health_updated(health)

export (float) var maxHealth = 500
export (float) var enemyDamage = 300

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
