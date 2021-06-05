extends CanvasLayer

var lobby_label = preload("res://assets/scenes/LobbyLabel.tscn")
var labelName = "Joas"
#var labelTimer = Timer.new()
var lastLabel
var showLabel
var labelNumber = 0

var labels = {}

func _ready():
	print("ready")
# warning-ignore:return_value_discarded
	gamestate.connect("on_player_join", self, "send_remote_player_name")
# warning-ignore:return_value_discarded
	gamestate.connect("on_player_leave", self, "_on_player_leave_event")
# warning-ignore:return_value_discarded
	gamestate.connect("lobby_created", self, "_on_lobby_created_event")
	showLabel = Timer.new()
	showLabel.set_wait_time(.01)
	showLabel.set_one_shot(true)
	add_child(showLabel)
	showLabel.connect("timeout", self, "labelShow") #[child]
#	showLabel.start()

func _process(_delta):
#	if Input.is_action_just_pressed("jump"):
#		send_remote_player_name()
#		var status_label
#		status_label = lobby_label.instance()
#		status_label.text = " " + labelName + " joined the room"
#		$Control/Panel/VBoxContainer.add_child(status_label)
#
#		labels[status_label] = [status_label.modulate.a, false]
#		lastLabel = status_label
		
#	if lastLabel != null:
	for label in labels:
		if label.visible == true: #<-- last step
			$Control/StatusIcon/Panel.visible = false
			$Control/StatusIcon/ChatIcon.visible = false
		if labels[label][0] == 1:
			if !labels[label][1]: #<-- fucking hell this took long
				var labelTimer = Timer.new()
				labelTimer.set_wait_time(3)
				labelTimer.set_one_shot(true)
				add_child(labelTimer)
				labelTimer.connect("timeout", self, "_on_labelTimer_timeout", [label])
				labelTimer.start()
				var chatPopup = Timer.new()
				chatPopup.set_wait_time(4)
				chatPopup.set_one_shot(true)
				add_child(chatPopup)
				chatPopup.connect("timeout", self, "_on_chatPopup_timeout")
				chatPopup.start()
				labels[label][1] = true
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
#	if label != null:
#		label.modulate.a -= .05
#		if label.modulate.a <= 0:
#			label.visible = false
#		else:
#			return label
#		labelTimer.set_wait_time(3)
#		labelTimer.set_one_shot(true)
#		add_child(labelTimer)
#		labelTimer.connect("timeout", self, "_on_labelTimer_timeout", [last_label])
#		labelTimer.start()
#
#func _on_labelTimer_timeout(label):
#	if label != null:
#		label.modulate.a -= .05
#		if label.modulate.a <= 0:
#			label.visible = false
#		else:
#			labelTimer.set_wait_time(float(1)/float(30))
#			labelTimer.start()

func _on_labelTimer_timeout(label):
	fade_label(label)

func _on_chatPopup_timeout():
	if get_node("/root/Lobby/cursor").visible:
		$Control/StatusIcon/Panel.visible = true
		$Control/StatusIcon/ChatIcon.visible = true

func _on_player_join_event(name):
	var status_label
	status_label = lobby_label.instance()
	status_label.text = " " + (str(name) + " joined the lobby")
	$Control/Panel/VBoxContainer.add_child(status_label)
	
	labels[status_label] = [status_label.modulate.a, false]

func _on_player_leave_event(_id, name):
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
#		showLabel = Timer.new()
#		showLabel.set_wait_time(.2)
#		showLabel.set_one_shot(true)
#		add_child(showLabel)
#		showLabel.connect("timeout", self, "labelShow", [child])
#		showLabel.start()
	$Control/StatusIcon/Panel.visible = false
	$Control/StatusIcon/ChatIcon.visible = false
	get_node("/root/Lobby/cursor").visible = false


func _on_StatusIcon_mouse_exited():
	for child in $Control/Panel/VBoxContainer.get_children():
		child.hide()
	$Control/StatusIcon/Panel.visible = true
	$Control/StatusIcon/ChatIcon.visible = true
	get_node("/root/Lobby/cursor").visible = true
	labelNumber = 0
	showLabel.stop()

func labelShow():
	$Control/Panel/VBoxContainer.get_children()[labelNumber].show()
	labelNumber += 1
	if labelNumber < $Control/Panel/VBoxContainer.get_children().size():
		showLabel.start()

var player_name
puppet var puppet_name

func send_remote_player_name(playerName):
	if is_network_master():
		player_name = playerName
		rset("player_name", puppet_name)
	else:
		player_name = puppet_name
	
	player_name = playerName
	if not is_network_master():
		puppet_name = player_name
	
	_on_player_join_event(player_name)
#	player_name = playerName
#	rpc("receive_remote_player_name", player_name)

sync func receive_remote_player_name(test):
	_on_player_join_event(test)
