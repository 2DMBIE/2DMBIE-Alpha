extends Node2D

var NoteArea = false

func _process(delta):
	if Input.is_action_just_pressed("use") && NoteArea == true:
		print("je bent dik")
	
func _on_notearea_body_entered(body):
	if body.is_in_group("player"):
		NoteArea = true


func _on_notearea_body_exited(body):
	if body.is_in_group("player"):
		NoteArea = false
