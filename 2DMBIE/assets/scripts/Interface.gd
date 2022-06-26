extends Control


func _physics_process(_delta):
	$WaveLabel.text = "wave" + " " + str(int(Global.Currentwave))
	$Scoreboard/PlayerScore.text = str(int(Global.Score))
	if Global.debug:
		$DebugMode.visible = true
	elif !Global.debug:
		$DebugMode.visible = false
