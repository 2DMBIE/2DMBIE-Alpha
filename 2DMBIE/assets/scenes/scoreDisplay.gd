extends VBoxContainer

var loaded = false

func _ready():
	pass

func _process(_delta):
	if loaded:
		var player_id = get_tree().get_network_unique_id()
		for child in get_children():
			if str(child.name) == str(player_id):
				rpc("set_score", player_id, str(Global.Score))

func on_players_loaded():
	loaded = true

remotesync func set_score(id, score):
	get_node(str(id) + "/Score").text = score
