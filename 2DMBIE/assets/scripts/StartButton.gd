extends CanvasLayer

onready var playerDisplay = preload("res://assets/scenes/PlayerDisplay.tscn")

var total_user_amount = 0
var user_amount = 0

var displayID
var player_display

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("on_player_join", self, "_on_player_joined")
	total_user_amount = gamestate.MAX_PEERS + 1
	
	if !get_tree().get_network_unique_id() == 1:
		$Control/Button.visible = false

func _process(_delta):
	user_amount = gamestate.players.size() + 1
	$Control/PlayerList/Panel/Label.text = str(user_amount) + " / " + str(total_user_amount)
	

func _on_Button_button_down():
	gamestate.begin_game()

func _on_player_joined(id, player_name):
	displayID = id
	print(displayID)
	player_display = playerDisplay.instance()
	player_display.name = str(id)
	player_display.get_node("NameDisplay/Label").text = " " + str(player_name)
	$Control/PlayerDisplays.add_child(player_display)
