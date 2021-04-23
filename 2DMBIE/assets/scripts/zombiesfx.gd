extends Node2D

func play_sound(library):
	var c = randi()%get_node(library).get_child_count()
	get_node(library).get_child(c).play()
