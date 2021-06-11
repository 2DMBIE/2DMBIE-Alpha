extends HBoxContainer

onready var greyColor = preload("res://assets/sprites/ColorSelectGrey.png")
onready var blueColor = preload("res://assets/sprites/ColorSelectBlue.png")
onready var redColor = preload("res://assets/sprites/ColorSelectRed.png")
onready var yellowColor = preload("res://assets/sprites/ColorSelectYellow.png")
onready var randomColor = preload("res://assets/sprites/ColorSelectRandom.png")

var colorArray
var selectNumber = 0

func _ready():
	colorArray = [randomColor, greyColor, blueColor, redColor, yellowColor]
	
# warning-ignore:return_value_discarded
	gamestate.connect("on_local_player_loaded", self, "_on_player_loaded")

func _process(_delta):
	if Input.is_action_just_pressed("jump"):
		print(get_node("/root/Lobby/Players").get_children())
	
	if !Global.paused:
		$LeftArrow.visible = false
		$RightArrow.visible = false
	elif Global.paused:
		if name == "PlayerDisplay":
			$LeftArrow.visible = true
			$RightArrow.visible = true

func _on_LeftArrow_button_down():
	selectNumber -= 1
	if selectNumber == -1:
		selectNumber = 3
	$ColorDisplay.texture = colorArray[selectNumber]

func _on_RightArrow_button_down():
	selectNumber += 1
	if selectNumber == 4:
		selectNumber = 0
	$ColorDisplay.texture = colorArray[selectNumber]

func _on_player_loaded():
	if is_network_master():
		print(get_node("/root/Lobby/Players").get_children())
		print(name)
		$ColorDisplay.texture = colorArray[get_node("/root/Lobby/Players").get_children().size()]
