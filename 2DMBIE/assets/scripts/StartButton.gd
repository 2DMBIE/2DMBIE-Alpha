extends CanvasLayer

var total_user_amount = 0
var user_amount = 0

func _ready():
	total_user_amount = gamestate.MAX_PEERS + 1
	
	if !get_tree().get_network_unique_id() == 1:
		$Control/Button.visible = false

func _process(delta):
	user_amount = gamestate.players.size() + 1
	$Control/Panel/Label.text = str(user_amount) + " / " + str(total_user_amount)


func _on_Button_button_down():
	gamestate.begin_game()
