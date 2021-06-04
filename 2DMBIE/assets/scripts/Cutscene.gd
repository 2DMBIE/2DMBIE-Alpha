extends Node2D


onready var anim = $AnimationPlayer
var numder = 0

func _ready():
	anim.play("Cutscene")
	$Timer.start(26)
	

func _on_Timer_timeout():
	get_node("Label").visible = !get_node("Label").visible
	$Timer.start(1)

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode != KEY_ENTER:
			numder += 1
			print('skip cutscene! '+str(numder))
