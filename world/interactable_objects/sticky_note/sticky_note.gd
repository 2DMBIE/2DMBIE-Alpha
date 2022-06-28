extends Node2D

var NoteArea = false
var noteActive = false

signal readNote()
signal closeNote()

func _process(_delta):
	if Input.is_action_just_pressed("use") && NoteArea == true:
		queue_free()
		emit_signal("readNote")
		noteActive = true
	
	if Input.is_action_just_pressed("escape") && noteActive == true:
		emit_signal("closeNote")
	
func _on_notearea_body_entered(body):
	if body.is_in_group("player"):
		NoteArea = true

func _on_notearea_body_exited(body):
	if body.is_in_group("player"):
		NoteArea = false
