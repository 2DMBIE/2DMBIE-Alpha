extends HBoxContainer


var can_change_key = false
var action_string
enum ACTIONS {jump, move_left, move_right, move_down}

# Called when the node enters the scene tree for the first time.
func _ready():
	_set_keys()


func _set_keys():
	pass
#	for i in ACTIONS:
#		var button = get_node("VBoxLeft/"+str(i)+"/Button")
#		button.set_pressed(false)
#		if !InputMap.get_action_list(i).empty():
#			button.set_text(InputMap.get_action_list(i)[0].as_text())
#		else:
#			button.set_text("No Keybind")

#		print("displays: "+button.get_text())
#		print("inputmap: "+InputMap.get_action_list(i)[0].as_text())


func _input(event):
	if event is InputEventKey:
		if can_change_key:
			_change_key(event)
			can_change_key = false
			
	if event.is_action_pressed("jump"):
		print('jump!!!')
	if event.is_action_pressed("move_left"):
		print('move_left!!!')
	if event.is_action_pressed("move_right"):
		print('move_right!!!')
	if event.is_action_pressed("move_down"):
		print('move_down!!!')
	if event.is_action_pressed("use"):
		_set_keys()


func _change_key(new_key):
	# Delete old key input
	if !InputMap.get_action_list(action_string):
		InputMap.action_erase_event(action_string, InputMap.get_action_list(action_string)[0])
	
	# Check for duplicate key input
	for i in ACTIONS:
		if InputMap.action_has_event(i, new_key):
			InputMap.action_erase_event(i, new_key)
	
	# Add new key input
	InputMap.action_add_event(action_string, new_key)
	
	_set_keys()


func _mark_button(string):
	can_change_key = true
	action_string = string
	
	for i in ACTIONS:
		if i != string:
			get_node("VBoxLeft/"+str(i)+"/Button").set_pressed(false)


func _on_jumpButton_pressed(): # uncomment these to get the script running
#	_mark_button("jump")
	pass
func _on_move_leftButton_pressed():
#	_mark_button("move_left")
	pass
func _on_move_rightButton_pressed():
#	_mark_button("move_right")
	pass
func _on_move_downButton_pressed():
#	_mark_button("move_down")
	pass
