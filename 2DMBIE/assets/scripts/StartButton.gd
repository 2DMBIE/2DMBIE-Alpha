extends CanvasLayer

var total_user_amount = 0
var user_amount = 0

func _ready():
	# warning-ignore:return_value_discarded
	#gamestate.connect("player_added", self, "_on_player_joined")
	total_user_amount = gamestate.MAX_PEERS + 1
	if !get_tree().get_network_unique_id() == 1:
		$Control/Button.visible = false

func _process(_delta):
	user_amount = gamestate.players.size() + 1
	$Control/PlayerList/Panel/Label.text = str(user_amount) + " / " + str(total_user_amount)
	
	if get_tree().get_network_unique_id() == 1:
		if Global.paused:
			$Control/Button.visible = false
		else:
			$Control/Button.visible = true
	

func _on_Button_button_down():
	gamestate.begin_game()

#	player_display = playerDisplay.instance()
#	player_display.name = str(id)
#	player_display.get_node("NameDisplay/Label").text = " " + str(player_name)
#	$Control/PlayerDisplays.add_child(player_display)
#	player_display.get_node("ColorSelect").on_player_loaded()
