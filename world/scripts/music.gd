extends Node2D

var playback_pos
var started = false

var musicnameArray = []
var rng = RandomNumberGenerator.new()
var music

func random_music():
	rng.randomize()
	musicnameArray = get_children()
	music = musicnameArray[rng.randi() % musicnameArray.size()]

func play_theme():
	music.play()
	started = true

func pause_theme():
	music.stop()
	playback_pos = music.get_playback_position()

func unpause_theme():
	if started:
		music.play(playback_pos)
	
func do_action(action):
	if !started:
		random_music()
	if action == "play":
		play_theme()
	elif action == "pause":
		pause_theme()
	elif action == "unpause":
		unpause_theme()
