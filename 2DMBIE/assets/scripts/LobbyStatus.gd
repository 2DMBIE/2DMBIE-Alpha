extends CanvasLayer

var lobby_label = preload("res://assets/scenes/LobbyLabel.tscn")
var labelName = "Joas"
var lastLabel
var showLabel
var labelNumber = 0

var labels = {}

func _ready():
# warning-ignore:return_value_discarded
	gamestate.connect("on_player_join", self, "_on_player_join_event")
# warning-ignore:return_value_discarded
	gamestate.connect("on_player_leave", self, "_on_player_leave_event")
# warning-ignore:return_value_discarded
	gamestate.connect("lobby_created", self, "_on_lobby_created_event")
	showLabel = Timer.new()
	showLabel.set_wait_time(.01)
	showLabel.set_one_shot(true)
	add_child(showLabel)
	showLabel.connect("timeout", self, "labelShow")

func _process(_delta):
	for label in labels: #<-- Loops through all labels in dictionary
		if label.visible == true: #<-- Hide icon if notification is visible
			$Control/StatusIcon/Panel.visible = false
		if labels[label][0] == 1: #<-- Run when opacity of label is 1
			if !labels[label][1]: #<-- Run timer when timer hasnt been started yet (boolean)
				var labelTimer = Timer.new()
				labelTimer.set_wait_time(3)
				labelTimer.set_one_shot(true)
				add_child(labelTimer)
				labelTimer.connect("timeout", self, "_on_labelTimer_timeout", [label])
				labelTimer.start()
				labels[label][1] = true #<-- Set boolean to false so timer doesnt run again
				var chatPopup = Timer.new()
				chatPopup.set_wait_time(4)
				chatPopup.set_one_shot(true)
				add_child(chatPopup)
				chatPopup.connect("timeout", self, "_on_chatPopup_timeout")
				chatPopup.start()
		else:
			fade_label(label)

func fade_label(label):
	label.modulate.a = lerp(label.modulate.a, 0, .1)
	if label.modulate.a <= 0.1:
		label.visible = false
		label.modulate.a = 0
		labels.erase(label)
	else:
		labels[label][0] = label.modulate.a

func _on_labelTimer_timeout(label):
	fade_label(label)

func _on_chatPopup_timeout():
	if get_node("/root/Lobby/cursor").visible:
		$Control/StatusIcon/Panel.visible = true

func _on_player_join_event(_id, name):
	var status_label
	status_label = lobby_label.instance()
	status_label.text = " " + (str(name) + " joined the lobby")
	$Control/Panel/VBoxContainer.add_child(status_label)
	
	labels[status_label] = [status_label.modulate.a, false]

func _on_player_leave_event(name):
	var status_label
	status_label = lobby_label.instance()
	status_label.text = " " + (str(name) + " left the lobby")
	$Control/Panel/VBoxContainer.add_child(status_label)
	
	labels[status_label] = [status_label.modulate.a, false]

func _on_lobby_created_event(name):
	var status_label
	status_label = lobby_label.instance()
	status_label.text = " " + (str(name) + " created a lobby")
	$Control/Panel/VBoxContainer.add_child(status_label)
	
	labels[status_label] = [status_label.modulate.a, false]

func _on_StatusIcon_mouse_entered():
	for child in $Control/Panel/VBoxContainer.get_children():
		child.modulate.a = 1
		if $Control/Panel/VBoxContainer/Label.rect_size.x >= 400:
			$Control/Panel.rect_clip_content = true
	labelShow()

	$Control/StatusIcon/Panel.visible = false
	get_node("/root/Lobby/cursor").visible = false


func _on_StatusIcon_mouse_exited():
	for child in $Control/Panel/VBoxContainer.get_children():
		child.hide()
	$Control/StatusIcon/Panel.visible = true
	get_node("/root/Lobby/cursor").visible = true
	labelNumber = 0
	showLabel.stop()

func labelShow():
	$Control/Panel/VBoxContainer.get_children()[labelNumber].show()
	labelNumber += 1
	if labelNumber < $Control/Panel/VBoxContainer.get_children().size():
		showLabel.start()
