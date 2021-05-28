extends Node2D

func play_sound(library):
	var c = randi()%get_node(library).get_child_count()
	get_node(library).get_child(c).play()

func play_sound_with_pitch(library, _pitch):
	var c = randi()%get_node(library).get_child_count()
	var node = get_node(library).get_child(c)
	node.pitch_scale = 2
	node.play()


func _on_purchasable_weapons_play_sound(library):
	play_sound(library)


func _on_Door_play_sound(library):
	play_sound(library)


func _on_Player_play_sound(library):
	play_sound(library)


func _on_gun_play_sound(value):
	play_sound(value)


func _on_gun_play_sound_with_pitch(value, pitch):
	play_sound_with_pitch(value, pitch)
