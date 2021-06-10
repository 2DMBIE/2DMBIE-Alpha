extends Node2D


onready var anim = $AnimationPlayer

func _ready():
	OS.window_fullscreen = true
	anim.play("Cutscene")
	$Timer.start(26)
	

func _on_Timer_timeout():
	get_node("Label").visible = !get_node("Label").visible
	$Timer.start(1)

func _input(event):
	if event is InputEventKey and event.pressed:
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://assets/scenes/mainmenu.tscn")
