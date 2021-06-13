extends Control

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var orangeColor = preload("res://assets/sprites/ColorSelectOrange.png")

onready var playerDisplay = preload("res://assets/scenes/PlayerDisplay.tscn")
onready var separator = preload("res://assets/scenes/Separator.tscn").instance()

onready var translate_color = {"Grey" : greyColor, "Blue" : blueColor, "Red" : redColor, "Orange" : orangeColor, "Random" : 0}

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
	print(gamestate.players_info)
	
	var player_display = playerDisplay.instance()
	player_display.name = str(id)
	player_display.get_node("NameDisplay/Label").text = " " + str(player_name)
	player_display.get_node("ColorDisplay").texture = translate_color[gamestate.players_info[id]["Color"]]
	$MultiScore/ScoreDisplays.add_child(player_display)
	
	$MultiScore/ScoreDisplays.add_child(separator)
	
	for p in gamestate.players:
		var PlayerDisplay = playerDisplay.instance()
		PlayerDisplay.name = str(p)
		PlayerDisplay.get_node("NameDisplay/Label").text = " " + str(gamestate.players_info[p]["Name"])
		PlayerDisplay.get_node("ColorDisplay").texture = translate_color[gamestate.players_info[p]["Color"]]
		$MultiScore/ScoreDisplays.add_child(PlayerDisplay)
	get_node("MultiScore/ScoreDisplays").on_players_loaded()
