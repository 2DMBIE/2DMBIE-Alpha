extends HBoxContainer

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var orangeColor = preload("res://assets/sprites/ColorSelectOrange.png")
#onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var colors
var selectNumber = 0
var path

func _ready():
	colors = { "Grey": greyColor, "Blue": blueColor, "Red": redColor, "Orange": orangeColor }

func _process(_delta):
	if Global.paused:
		$ColorDisplay.visible = false
		$LeftArrow.disabled = true
		$LeftArrow.visible = false
		$RightArrow.disabled = true
		$RightArrow.visible = false
	else:
		$ColorDisplay.visible = true
		$LeftArrow.disabled = false
		$LeftArrow.visible = true
		$RightArrow.disabled = false
		$RightArrow.visible = true

func on_player_loaded():
	path = "/root/Lobby/Players/" + str(gamestate.player_id)
	#getPlayer().
	#print(get_node("/root/Lobby/Players").get_children())
	#_on_RightArrow_button_down()

func _on_right_button_down():
	selectNumber += 1
	if selectNumber == 4:
		selectNumber = 0
	$ColorDisplay.texture = colors.values()[selectNumber]


func _on_left_button_down():
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 3
	$ColorDisplay.texture = colors.values()[selectNumber]

func getPlayer():
	return get_tree().root.get_node_or_null(path)
