extends HSlider

export (String, "Master", "Music", "Soundeffects") var audio_bus

onready var _bus := AudioServer.get_bus_index(audio_bus)

func _ready():
	value = db2linear(AudioServer.get_bus_volume_db(_bus))

func on_value_changed(value):
	AudioServer.set_bus_volume_db(_bus, linear2db(value))
