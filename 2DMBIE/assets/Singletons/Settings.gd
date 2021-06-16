extends Node

var master_volume: float
var music_volume: float
var soundeffects_volume: float
var aim: bool
var camera: bool
var brightness: bool
var debugMode: bool
var fullscreen: bool

func loadSettings():
	var Config = File.new()
	if not Config.file_exists("user://Config"):
		return
	Config.open("user://Config", File.READ)
	master_volume = Config.get_float()
	music_volume = Config.get_float()
	soundeffects_volume = Config.get_float()
	aim = Config.get_var()
	camera = Config.get_var()
	brightness = Config.get_var()
	debugMode = Config.get_var()
	fullscreen = Config.get_var()
	Config.close()
