extends HBoxContainer

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var orangeColor = preload("res://assets/sprites/ColorSelectOrange.png")
onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var colors
var selectNumber = 0

func _ready():
	colors = [randomColor, greyColor, blueColor, redColor, orangeColor]

func _on_LeftArrow_button_down():
	print("left")
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 4
	$ColorDisplay.texture = colors[selectNumber]
	#prevColor = colors[selectNumber]
	#rpc("set_player_color", prevColor)

func _on_RightArrow_button_down():
	print("right")
	selectNumber += 1
	if selectNumber == 5:
		selectNumber = 0
	$ColorDisplay.texture = colors[selectNumber]
	#prevColor = colors[selectNumber]
	#rpc("set_player_color", prevColor)

func on_player_loaded():
	print(get_node("/root/Lobby/Players").get_children())
	#_on_RightArrow_button_down()


func _on_RightArrow_pressed():
	print("right11")
	selectNumber += 1
	if selectNumber == 5:
		selectNumber = 0
	$ColorDisplay.texture = colors[selectNumber]


func _on_LeftArrow_pressed():
	print("left22")
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 4
	$ColorDisplay.texture = colors[selectNumber]
	#prevColor = colors[selectNumber]


func _on_LeftArrow_button_down2():
	print("Yeey")
