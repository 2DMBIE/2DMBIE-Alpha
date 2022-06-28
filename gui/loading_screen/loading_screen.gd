extends Node2D

var tips = [
	"You can view your controls in the options menu!",
	"You can view your controls in the options menu!",
	"You can view your controls in the options menu!",
	"Dying is not good for you!",
	"You can use score to buy everything! (if you have enough :D)"
]
var rng = RandomNumberGenerator.new()

func _ready():
	setTooltip()
	$Timer.start(0)

func _on_Timer_timeout():
	setTooltip()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://world/world.tscn")

func setTooltip():
	rng.randomize()
	$HBox/VBox/Panel/HBox/VBox/Tooltip.text = tips[rng.randi() % tips.size()]
