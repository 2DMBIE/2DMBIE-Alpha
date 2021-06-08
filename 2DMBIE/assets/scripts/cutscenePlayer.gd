extends Node2D



onready var anim = $PlayerAnimation

# Called when the node enters the scene tree for the first time.
func _ready():
	anim.play("runCutscene")
