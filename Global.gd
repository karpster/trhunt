extends Node

var spacing: float = 3
var players_dict = {} # controller_id: player_id
var map_width: int = 7
var map_height: int = 7
var eventdevice
var validcheck: bool

func identify_input(pressed_event):
	# check if device of event is keyboard or controller
	validcheck = false
	if pressed_event is InputEventMouseMotion or pressed_event is InputEventMouseButton:
		validcheck = false
	elif (pressed_event is InputEventJoypadButton):
		eventdevice = pressed_event.get_device()
		validcheck = true
	elif pressed_event is InputEventJoypadMotion && pressed_event.get_axis() >= 0 && pressed_event.get_axis() <= 3:
		eventdevice = pressed_event.get_device()
		validcheck = true
	elif pressed_event is InputEventJoypadMotion && pressed_event.get_axis() >= 4:
		validcheck = false
	else:
		eventdevice = "keyboard"
		validcheck = true
