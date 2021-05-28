extends Control

var messages = ['Well played!', 'Good games!', 'Better luck next time!', 'You did great!', 'You have displayed extraordinary skills!']
var fontSize
var rng = RandomNumberGenerator.new()
var colorSpeed = 0.0075
onready var fontOutline = $VBOX/Title.get_font("font")
onready var fontRed = 1
onready var fontGreen = 1
onready var fontBlue = 1

func _ready():
	randomize()
	$VBOX/Label.text = messages[randi() % messages.size()]
	fontOutline.outline_color = Color.white
	rng.randomize()
	fontRed = rng.randf()
	fontGreen = rng.randf()
	fontBlue = rng.randf()


func _process(_delta):
	$VBOX/HBox/VBox/Score/Score.text = str(Global.Score)
	$VBOX/HBox/VBox/Wave/Wave.text = str(Global.Currentwave)
	
	if visible:
		if !$AudioStreamPlayer.playing:
			$AudioStreamPlayer.play()
		fontOutline = $VBOX/Title.get_font("font")
		if $VBOX/Title.get_font("font").size >= 96:
			$VBOX/Title.get_font("font").size -= 0.5
#			rng.randomize()
			print(fontRed, " | ", fontGreen, " | ", fontBlue)
			fontOutline.outline_color = Color(fontRed, fontGreen, fontBlue)
			fontRed -= colorSpeed
			fontGreen -= colorSpeed
			fontBlue -= colorSpeed
		else:
			$VBOX/Title.get_font("font").outline_color = Color.black
			$VBOX/HBox.visible = true
			$VBOX/PlayAgainButton.visible = true
			$VBOX/ExitToMenu.visible = true