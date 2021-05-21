extends Control

func _ready():
	$redBorder/Sprite.visible = false
	$redBorder2/Sprite.visible = false
	$redBorder3/Sprite.visible = false
	$redBorder4/Sprite.visible = false

func _on_Player_health_updated(health, maxHealth):
	var percentageHP = int((float(health) / maxHealth * 100))
	if percentageHP <= 30:
		$redBorder/Sprite.visible = true
		$redBorder2/Sprite.visible = true
		$redBorder3/Sprite.visible = true
		$redBorder4/Sprite.visible = true
	else:
		$redBorder/Sprite.visible = false
		$redBorder2/Sprite.visible = false
		$redBorder3/Sprite.visible = false
		$redBorder4/Sprite.visible = false
