extends Node2D

var playback_pos
var started = false

func play_theme():
	get_node("ingame_music").play()
	started = true

func pause_theme():
	get_node("ingame_music").stop()
	playback_pos = get_node("ingame_music").get_playback_position()

func unpause_theme():
	if started:
		get_node("ingame_music").play(playback_pos)
	
func do_action(action):
	if action == "play":
		play_theme()
	elif action == "pause":
		pause_theme()
	elif action == "unpause":
		unpause_theme()
