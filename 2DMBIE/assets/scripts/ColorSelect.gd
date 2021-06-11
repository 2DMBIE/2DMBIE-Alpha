extends HBoxContainer

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var yellowColor = preload("res://assets/sprites/ColorSelectYellow.png")
onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var colorArray
var selectNumber = 0
var prevColor

func _ready():
	colorArray = [randomColor, greyColor, blueColor, redColor, yellowColor]

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		print(get_node("/root/Lobby/Players").get_children())
	
	if !Global.paused:
		$LeftArrow.visible = false
		$RightArrow.visible = false
	elif Global.paused:
		if get_parent().name == str(get_tree().get_network_unique_id()):
			$LeftArrow.visible = true
			$RightArrow.visible = true

func _on_LeftArrow_button_down():
	if prevColor != null:
		colorArray.insert(selectNumber, prevColor)
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 4
	$ColorDisplay.texture = colorArray[selectNumber]
	prevColor = colorArray[selectNumber]
	rpc("set_player_color", prevColor)

func _on_RightArrow_button_down():
	if prevColor != null:
		colorArray.insert(selectNumber, prevColor)
	selectNumber += 1
	if selectNumber == 5:
		selectNumber = 0
	$ColorDisplay.texture = colorArray[selectNumber]
	prevColor = colorArray[selectNumber]
	rpc("set_player_color", prevColor)

func on_player_loaded():
	print(get_node("/root/Lobby/Players").get_children())
	_on_RightArrow_button_down()

remotesync func set_player_color(prevColor):
	colorArray.erase(prevColor)
#	print(colorArray)
