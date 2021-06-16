extends Node2D

var musicBox = false

func play_sound(library):
	var c = randi()%get_node(library).get_child_count()
	get_node(library).get_child(c).play()
	if musicBox == true:
		Global.boxMusicNode = get_node(library).get_child(c)
	musicBox = false

func play_sound_with_pitch(library, _pitch):
	var c = randi()%get_node(library).get_child_count()
	var node = get_node(library).get_child(c)
	node.pitch_scale = 2
	node.play()


func _on_purchasable_weapons_play_sound(library):
	play_sound(library)


func _on_Door_play_sound(library):
	play_sound(library)


func _on_puck_a_panch_play_sound(library):
	musicBox = true
	play_sound(library)
	


func _on_purchasable_perks_play_sound(library):
	play_sound(library)
