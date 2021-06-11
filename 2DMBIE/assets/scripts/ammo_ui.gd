extends Label

var gunscript

var _ammo
var _maxclip_ammo 
var _total_ammo

func _ready():
	# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "_on_player_loaded")	

func _process(_delta):
	if gunscript != null:
		var _gun:= Gun
		_gun = gunscript.get_current_gun()
		get_node("TotalAmmoLabel").text = str(_gun.totalAmmo)
		get_node("AmmoLabel").text = "(" + str(_gun.ammo) + '/' + str(_gun.maxclipAmmo) + ")"

func _on_player_loaded():
	if get_tree().root.has_node("/root/World"):
		gunscript = get_node("/root/World/Players/" + str(gamestate.player_id)+ "/body/chest/torso/gun")
