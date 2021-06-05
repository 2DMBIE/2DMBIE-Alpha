extends CanvasLayer

var total_user_amount = 0
var user_amount = 0

func _ready():
	total_user_amount = gamestate.MAX_PEERS + 1

func _process(_delta):
	user_amount = gamestate.players.size() + 1
	$Control/Panel/Label.text = str(user_amount) + " / " + str(total_user_amount)
