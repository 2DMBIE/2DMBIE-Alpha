extends HBoxContainer

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var yellowColor = preload("res://assets/sprites/ColorSelectYellow.png")
onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var colorArray
var selectNumber = 2
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
	colorArray.erase(prevColor)
	for value in colorArray:
		print(value.load_path)

func _on_RightArrow_button_down():
	selectNumber += 1
	if selectNumber == 4:
		selectNumber = 0
	$ColorDisplay.texture = colorArray[selectNumber]

func on_player_loaded():
	print(get_node("/root/Lobby/Players").get_children())
	_on_LeftArrow_button_down()
