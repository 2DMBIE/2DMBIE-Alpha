extends Control

var messages = ['Well played!', 'Good games!', 'Better luck next time!', 'You did great!', 'You have displayed extraordinary skills!']

func _ready():
	randomize()
	$HBox/VBox/Label.text = messages[randi() % messages.size()]


func _process(_delta):
	$HBox/VBox/Score/Score.text = str(Global.Score)
