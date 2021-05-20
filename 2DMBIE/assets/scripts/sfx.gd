extends Node2D

func play_sound(library):
	var c = randi()%get_node(library).get_child_count()
	get_node(library).get_child(c).play()

func play_sound_with_pitch(library, pitch):
	var c = randi()%get_node(library).get_child_count()
	var node = get_node(library).get_child(c)
	node.pitch_scale = 2
	node.play()
