extends Control

func _ready():
	# Called every time the node is added to the scene.
	# Make it a variable, so the warning message is ignored
	
	# warning-ignore:return_value_discarded
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	# warning-ignore:return_value_discarded
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	# warning-ignore:return_value_discarded
	gamestate.connect("game_ended", self, "_on_game_ended")
	# warning-ignore:return_value_discarded
	gamestate.connect("game_error", self, "_on_game_error")

	# Set the player name according to the system username. Fallback to the path.
	if OS.has_environment("USERNAME"):
		$Connect/Name.text = OS.get_environment("USERNAME")
	else:
		var desktop_path = OS.get_system_dir(0).replace("\\", "/").split("/")
		$Connect/Name.text = desktop_path[desktop_path.size() - 2]
	var ip_addresses = IP.get_local_addresses()
	var i = 0
	for ip in ip_addresses:
		if ip == "127.0.0.1":
			break
		i = i+1
	ip_addresses.remove(i) # remove 127.0.0.1 from list
	for ip in ip_addresses:
		i = 1
		for character in ip:
			if character == ".": # get address with 4 dots cause ipv4: ...x...x...x...
				i = i+1
			if i >= 4:
				$Connect/DeviceIP.text = ip
		
func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""

	var player_name = $Connect/Name.text
	gamestate.host_game(player_name)
	gamestate.load_lobby()

func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return

	var ip = $Connect/IPAddress.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return

	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true
	$Connect/Cancel.visible = true
	$Connect/Cancel.disabled = false
	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name)


func _on_connection_success():
	$Connect.hide()
	$Players.show()
	gamestate.load_lobby()

func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")


func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/Cancel.visible = false
	$Connect/Cancel.disabled = false


func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false


func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p)

	$Players/Start.disabled = not get_tree().is_network_server()


func _on_start_pressed():
	gamestate.start_lobby()

func _on_find_public_ip_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://www.whatismyip.com/")


func _on_cancel_pressed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/Cancel.visible = false
