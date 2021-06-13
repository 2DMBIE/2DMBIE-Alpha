extends HBoxContainer

var translate_number = {0 : "Grey", 1 : "Blue", 2 : "Red", 3 : "Orange"}

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var orangeColor = preload("res://assets/sprites/ColorSelectOrange.png")
onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var rng = RandomNumberGenerator.new()

var colors
var selectNumber = 0
var path
var loaded = false
var new_number = 0

func _ready():
	# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "on_players_loaded")
	gamestate.connect("on_player_join", self, "on_player_join")
	colors = { "Grey": greyColor, "Blue": blueColor, "Red": redColor, "Orange": orangeColor, "Random" : randomColor }
	$ColorDisplay.texture = colors["Grey"]

func _process(_delta):
	if Global.paused:
		$LeftArrow.visible = true
		$RightArrow.visible = true
		rect_position.y = 110
	else:
		$LeftArrow.visible = false
		$RightArrow.visible = false
		rect_position.y = 15

func on_player_loaded():
	path = "/root/Lobby/Players/" + str(gamestate.player_id)
	#print(get_node("/root/Lobby/Players").get_children())
	#_on_RightArrow_button_down()

func _on_right_button_down():
	selectNumber += 1
	if selectNumber == 5:
		selectNumber = 0
	change_color()

func _on_left_button_down():
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 4
	change_color()

func getPlayer():
	return get_tree().root.get_node_or_null(path)

remotesync func add_color(id, number):
	if loaded:
		gamestate.players_info[id]["Color"] = translate_number[number]
		get_node("/root/Lobby/Players/" + str(id)).set_color(number)

func on_players_loaded():
	loaded = true
	rpc("add_color", gamestate.player_id, new_number)

func change_color():
	if selectNumber == 4:
		rng.randomize()
		new_number = rng.randi() % 4
	else:
		new_number = selectNumber
	rpc("add_color", gamestate.player_id, new_number)
	$ColorDisplay.texture = colors.values()[selectNumber]

func on_player_join(_id, _name):
	change_color()
