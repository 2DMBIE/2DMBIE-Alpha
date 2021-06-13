extends Control

onready var playerDisplay = preload("res://assets/scenes/PlayerDisplay.tscn")

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("player_added", self, "_on_host_joined")
	
	if Global.online:
		$MultiScore.visible = true
		$SingleScore.visible = false
	else:
		$SingleScore.visible = false
		$MultiScore.visible = true

func _physics_process(_delta):
	$WaveLabel.text = "wave" + " " + str(int(Global.Currentwave))
	$SingleScore/PlayerScore.text = str(int(Global.Score))

func _on_host_joined(id, player_name):
	var player_display = playerDisplay.instance()
	player_display.name = str(id)
	player_display.get_node("NameDisplay/Label").text = " " + str(player_name)
	$MultiScore/ScoreDisplays.add_child(player_display)
	
	for p in gamestate.players:
		var PlayerDisplay = playerDisplay.instance()
		PlayerDisplay.name = str(p)
		PlayerDisplay.get_node("NameDisplay/Label").text = " " + str(gamestate.players[p])
		$MultiScore/ScoreDisplays.add_child(PlayerDisplay)
	get_node("MultiScore/ScoreDisplays").on_players_loaded()
