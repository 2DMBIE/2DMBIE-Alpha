extends Control

var is_playing_heartbeat_sound = false
signal play_sound(library)

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
		if not is_playing_heartbeat_sound:
			emit_signal("play_sound", "heartbeat")
			is_playing_heartbeat_sound = true
	else:
		$redBorder/Sprite.visible = false
		$redBorder2/Sprite.visible = false
		$redBorder3/Sprite.visible = false
		$redBorder4/Sprite.visible = false
		is_playing_heartbeat_sound = false
